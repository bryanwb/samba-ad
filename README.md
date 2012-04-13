Description
===========

Installs and configures Samba version 3 to work with kerberos and Windows active Directory

Requirements
============

Assumes Samba version 3.

Should work on Debian-family, Red Hat-family and ArchLinux systems.

Uses Chef Server for data bag to build configuration file shares.

This cookbook connect to Windows Active Directory via Kerberos

The "/etc/samba/smbusers" file maps unix user names to Active Directory logons

The actual authentication is done by Kerberos

Limitations
===========

Does not (yet) integrate with LDAP/AD.

Uses plaintext passwords for the user data bag entry to create the SMB users if the password backend is tdbsam or smbpasswd. See below under usage.

Does not modify the Samba daemons to launch (i.e., ArchLinux's `/etc/conf.d/samba` `SAMBA_DAMONS`).

Attributes
==========

The attributes are used to set up the default values in the smb.conf, and set default locations used in the recipe. Where appropriate, the attributes use the default values in Samba.

* `node["samba"]["workgroup"]` - The SMB workgroup to use, default "SAMBA".
* `node["samba"]["interfaces"]` - Interfaces to listen on, default "lo 127.0.0.1".
* `node["samba"]["hosts_allow"]` - Allowed hosts/networks, default "127.0.0.0/8".
* `node["samba"]["bind_interfaces_only"]` - Limit interfaces to serve SMB, default "no"
* `node["samba"]["server_string"]` - Server string value, default "Samba Server".
* `node["samba"]["load_printers"]` - Whether to load printers, default "no".
* `node["samba"]["passdb_backend"]` - Which password backend to use, default "tdbsam".
* `node["samba"]["dns_proxy"]` - Whether to search NetBIOS names through DNS, default "no".
* `node["samba"]["security"]` - Samba security mode, default "user".
* `node["samba"]["map_to_guest"]` - What Samba should do with logins that don't match Unix users, default "Bad User".
* `node["samba"]["socket_options"]` - Socket options, default "`TCP_NODELAY`"
* `node["samba"]["config"]` - Location of Samba configuration, default "/etc/samba/smb.conf".
* `node["samba"]["log_dir"]` - Location of Samba logs, default "/var/log/samba/%m.log".


Recipes
=======

client
------

Installs smbclient to provide access to SMB shares.

default
-------

Includes the client recipe by default.

server
------

Sets up a Samba server. See "Usage" below for more information.


Usage
=====

The `samba::default` recipe includes `samba::client`, which simply installs smbclient package. Remaining information in this section pertains to `samba::server` recipe.

Set attributes as desired in a role, and create a data bag named `samba` with an item called `shares`. Also create a `users` data bag with an item for each user that should have access to samba.

Example data bag item for a single share named `export` in the `shares` item.

    % cat data_bags/samba_shares/logs.json
    {
      "id": "logs",
      "comment": "Everybody loves logs",
			"path": "/logs",
			"guest ok": "no",
			"printable": "no",
			"read list": [ "infosec" ],
			"write list": ["jtimberman"],
			"create mask": "0664",
			"directory mask": "0775"
    }


Example data bag item for a user. Note that the user must exist on the system already. This is the minimal users data bag to set up the `smbpasswd` entry. More options are available for those using the `users` cookbook, see the readme for that cookbook for more information.

    % cat data_bags/users/jtimberman.json
    {
      "id": "jtimberman",
			"groups": [ "developers", "infosec" ],
			"ad_domain": "BIG_CORP_HQ"
    }


License and Author
==================

Author:: Bryan W. Berry (<bryan.berry@gmail.com>)

Copyright:: 2011, Bryan W. Berry

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
