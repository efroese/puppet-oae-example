# = Class: yourkit
#
# This class downloads and extracts yourkit.
#
# == Paramters:
#
# $user:: The owner of $rootDir (required)
#
# $group:: The owner of $rootDir (required)
#
# $mode:: The file permission mode of $rootDir
# 
# $remoteFileName:: The remote filename of the yourkit tar.bz2 file. Automatically
# downloaded from "http://www.yourkit.com/download/${remoteFileName}.tar.bz2"
#
# $rootDir:: The base directory under which to extract YourKit. The actual YourKit
# directory will wind up being "$rootDir/localFileName".
#
# $localFileName:: The directory that represents the top-level directory of the downloaded
# YourKit package. This class does not ensure that YourKit is extracted here, you must
# know what the extraction location will be and tell that to the class to avoid always
# downloading the package when it already exists.
#
# == Actions:
#   Downloads the YourKit Java profiler if $rootDir/$localFileName does not exist
#   Extracts YourKit to the $rootDir
#
class yourkit ( $user,
                $group,
                $mode = '0755',
                $remoteFileName = 'yjp-11.0.8-linux',
                $localFileName = 'yjp-11.0.8',
                $rootDir = '/usr/local/yourkit',) {

    # Public variables
    $root_dir = $rootDir
    $base_dir = $localFileName

    file { $rootDir:
      ensure    => directory,
      owner     => $user,
      group     => $group,
      mode      => $mode,
    }

    archive { "${remoteFileName}":
      url             => "http://www.yourkit.com/download/${remoteFileName}.tar.bz2",
      target          => $rootDir,
      extension       => "tar.bz2",
      checksum        => false,
      allow_insecure  => true,
      timeout         => 0,
      creates         => "${rootDir}/${localFileName}",
      require         => File[$rootDir]
    }

}