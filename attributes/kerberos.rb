#
# Cookbook Name:: samba
# Attributes:: kerberos 
#
# Copyright 2011, Bryan W. Berry
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default["kerberos"]["config"] = "/etc/krb5.conf"
default["kerberos"]["realm"] = "EXAMPLE.COM"
default["kerberos"]["kdc_servers"] = [ "kdc.example.com" ]
default["kerberos"]["kdc_port"] = "88"
default["kerberos"]["admin_server"] =  "kadmin.example.com" 
default["kerberos"]["admin_port"] = "749"
