#!/usr/bin/env ruby

# =====================================================================
# = A script to parse OAE data to inform analytics                    =
# = https://jira.rsmart.com/browse/ACAD-722                           =
# =====================================================================

require 'rubygems'
require 'net/http'
require 'net/https'
require 'net/scp'
require 'net/sftp'
require 'optparse'
require 'json'
require 'csv'
require 'tempfile'
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar

# A Net::HTTP request wrapper
# Modified version of existing code at
## https://github.com/croby/github-pr-manager/blob/master/manager.rb
def do_request(uri, user, password, method = 'GET', args = {})
  uri = URI(uri)

  case method
  when 'POST'
    req = Net::HTTP::Post.new(uri.request_uri)
  when 'PATCH'
    req = Net::HTTP::Post.new(uri.request_uri)
  else
    req = Net::HTTP::Get.new(uri.request_uri)
  end

  unless args.empty?
    req.body = args.to_json
  end

  req.basic_auth user, password

  http = Net::HTTP.new(uri.host, uri.port)
  if uri.scheme.eql? 'https'
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
  res = http.start do |http| http.request(req) end
  JSON.parse(res.body)
end

# ===========
# = Globals =
# ===========

@users = {}
@worlds = []
@activity = []
@loglines = []
@logfiles = []
@directory_name = nil
@options = nil


# ========================
# = Data parsing methods =
# ========================

# Parse out the worlds.txt file
def parse_worlds_file
  File.open("worlds.txt", "r").each do |line|
    world = line.strip
    unless world.empty?
      @worlds.push(world)
    end
  end
end

# Grab all the users for each world specified in worlds.txt
def get_users
  @worlds.each do |world|
    world_url = @options[:server] + "/system/userManager/group/#{world}.json"
    world_json = do_request(world_url, "admin", @options[:password])
    roles = JSON.parse(world_json["properties"]["sakai:roles"])
    role_urls = []
    # Grab the users in each role in the world
    roles.each do |role|
      role_users = do_request(@options[:server] + "/system/userManager/group/#{world}-#{role["id"]}.everyone.json", "admin", @options[:password])
      role_users.each do |user|
        unless user.size.eql? 0
          @users[user["userid"]] ||= []
          @users[user["userid"]].push({
            "world" => world,
            "role" => role["id"]
          })
        end
      end
    end
  end
end

# Grab all the activity in the system
def get_activity
  more_activities = true
  activities = []
  offset = 0
  # Newer nakamura installs will only return up to 100 items
  # To retrieve them all, we need to request inside a loop
  while more_activities
    tmpactivities = do_request(@options[:server] + "/var/search/activity/all.json?items=100&page=#{offset}", "admin", @options[:password])
    activities.concat tmpactivities["results"]
    offset += 1
    if tmpactivities["total"] < offset*100
      more_activities = false
    end
  end
  activities.each do |activity|
    # only keep activities with users we're interested in
    if @users.keys.include? activity["who"]["userid"]
      @activity.push activity.to_json.to_s
    end
  end
end

# scp the logs to a local directory
def get_remote_logs
  @options[:remotes].each do |remote|
    Net::SCP.start(remote, @options[:user]) do |scp|
      file = Tempfile.new('scpfile')
      path = @options[:path]
      if @options[:append]
        path += ".#{(Time.now - 86400).strftime("%Y-%m-%d")}"
      end
      file << scp.download!(path)
      file.close
      @logfiles.push(file)
    end
  end
end

# Parse the given nakamura log file
def parse_log
  @logfiles.each do |logfile|
    File.open(logfile.path, "r").each do |line|
      # Ignore assets and commonly made requests
      stopwords = [".css", ".js", ".png", ".jpg", ".json", ".gif", ".html", "/pubspace", "/privspace", "/system/batch", "/system/me"]
      ignore = false
      stopwords.each do |stop|
        if line.include? stop + " HTTP/1.1"
          ignore = true
          break
        end
      end
      unless ignore
        # Only get lines that include a user we're interested in
        @users.keys.each do |userid|
          if line.include? " - #{userid} "
            @loglines.push(line.strip)
            break
          end
        end
      end
    end
  end
end

# ==================
# = Output methods =
# ==================

# Create a new folder with the current timestamp to place the files in
def create_timestamped_folder
  @directory_name = Dir::pwd + "/" + Time.now.to_f.to_i.to_s
  Dir::mkdir @directory_name
end

def delete_timestamped_folder
  FileUtils.rm_rf @directory_name
end

def write_activity_file
  File.open(@directory_name + "/activity.log", 'w') do |f|
    f.write @activity.join("\n\n")
  end
end

def write_filtered_log
  File.open(@directory_name + "/loglines.log", 'w') do |f|
    f.write @loglines.join("\n\n")
  end
end

# Write a CSV file with the user + world + role data
def write_users_roles
  CSV.open(@directory_name + "/roles.csv", 'wb') do |f|
    f << ["userid", "world", "role"]
    @users.each_pair do |userid, data|
      data.each do |world|
        f << [userid, world["world"], world["role"]]
      end
    end
  end
end

def upload_to_server
  # Time.now - 86400 is yesterday
  filename = "#{(Time.now - 86400).strftime("%Y-%m-%d")}"

  # Crate the tar file
  File.open("#{filename}.tar", 'wb') do |tar|
    owd = Dir::pwd
    # Minitar uses Find.find internally, so we have to be in the right directory
    Dir.chdir @directory_name
    Minitar.pack('.', tar)
    Dir.chdir owd
  end

  # gzip the tar file
  Zlib::GzipWriter.open("#{@directory_name}/#{filename}.tar.gz") do |gz|
    gz.write IO.read("#{filename}.tar")
  end

  # remove the original tar file
  FileUtils.rm_rf "#{filename}.tar"

  # Upload the file
  path = "#{@options[:uploadpath]}/#{filename}.tar.gz"
  Net::SFTP.start(@options[:uploadserver], @options[:user]) do |sftp|
    sftp.upload!("#{@directory_name}/#{filename}.tar.gz", path)
  end
end

# Parse the commandline options
def parse_options
  options = {}

  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: ./parse_logs.rb -s server -p password -u remoteuser -t /path/to/remote/file -r remoteserver1,remoteserver2 [-x uploadserver] [-m uploadpath] [-a,--append]"
    opts.on('-s', '--server SERVER', 'The server to connect to (ie. http://dev.academic.rsmart.com)') do |s|
      options[:server] = s
    end
    opts.on('-p', '--password PASSWORD', 'The admin password for the server') do |p|
      options[:password] = p
    end
    opts.on('-r', '--remote x,y,z', 'The remote servers to get the log from') do |r|
      options[:remotes] = r.split(',')
    end
    opts.on('-u', '--user USER', 'The user for the remote servers') do |u|
      options[:user] = u
    end
    opts.on('-t', '--path PATH', 'The path to the file on the server') do |t|
      options[:path] = t
    end
    opts.on('-x', '--upload SERVER', 'The server to upload the results to') do |x|
      options[:uploadserver] = x
    end
    opts.on('-m', '--uploadpath PATH', 'The path on the upload server to upload to') do |m|
      options[:uploadpath] = m
    end
    opts.on('-a', '--append', 'If we should append yesterdays date to the remote log file name') do |a|
      options[:append] = true
    end
    opts.on( '-h', '--help', 'Display this screen' ) do
      puts opts
      exit
    end
  end

  optparse.parse!

  # server and password are required options
  unless options[:server] && options[:password] && options[:remotes] && options[:user] && options[:path]
    puts optparse
    exit(-1)
  end
  options
end

# ================
# = Main program =
# ================

def main
  @options = parse_options
  parse_worlds_file
  get_users
  get_activity
  get_remote_logs
  parse_log
  create_timestamped_folder
  write_activity_file
  write_filtered_log
  write_users_roles
  if @options[:uploadserver] && @options[:uploadpath]
    upload_to_server
    delete_timestamped_folder
  end
end

main
