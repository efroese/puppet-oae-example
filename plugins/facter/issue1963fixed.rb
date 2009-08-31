Facter.add("issue1963fixed") do
  setcode do

    sha1sum = "48e6284d2966b61574bdb233d9826fc6d1c079a3"

    begin
      Facter.rubysitedir
    rescue
      Facter.loadfacts()
    end

    if Facter.value('puppetversion') != '0.24.7'
      response = "yes"
    else

      rubysitedir = Facter.value('rubysitedir')
      file = rubysitedir + "/puppet/util/selinux.rb"

      if FileTest.exists?(file) and FileTest.file?(file)

        require 'digest/sha1'
        hash_func = Digest::SHA1.new
        open(file, "r") do |io|
          while (!io.eof)
            readBuf = io.readpartial(1024)
            hash_func.update(readBuf)
          end
        end

        if hash_func.hexdigest == sha1sum
          response = "yes"
        else
          response = "no"
        end

      else
        response = "no"
      end

    end
  end
end
