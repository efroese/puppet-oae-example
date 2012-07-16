# dnsLookup.rb
# does a DNS lookup and returns a string of the IP
 
require 'resolv'
 
module Puppet::Parser::Functions
    newfunction(:dnsLookup, :type => :rvalue) do |args|
        result = []
        result = Resolv.new.getaddress(args[0])
        return result
    end
end
