maintainer       "Bryan W. Berry"
maintainer_email "bryan.berry@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures samba to use Active Directory via Kerberos"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

recipe "samba::default", "Includes the samba::client recipe"
recipe "samba::client", "Installs smbclient package"
recipe "samba::server", "Installs samba server packages and configures smb.conf"

%w{ arch debian ubuntu centos fedora redhat }.each do |os|
  supports os
end
