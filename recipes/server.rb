#
# Cookbook Name:: samba
# Recipe:: server 
#
# Copyright 2011,  Bryan W. Berry
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
#

# get acct and passwd for joining Active Directory domain from
# encrypted data bag
db = Chef::EncryptedDataBagItem.load("stash", "stuff")
ENV['AD_RXVTU'] = db["ad_#{node['samba']['realm']}RXVTU"]
ENV['AD_RXVTP'] = db["ad_#{node['samba']['realm']}RXVTP"]
smb_realm = node['samba']['realm']

users = []
groups = []
shares = []

if node[:samba][:shares] != nil
	share_names = node[:samba][:shares] 
else
	share_names = []
end

share_names.each do |share_name|
	shares << data_bag_item("smb_shares", share_name)
	groups <<	shares.last['write list'] << shares.last['read list'] 
end

if not groups.empty?
	groups.flatten!.uniq!
end

user_data_bags = []
groups.each do |group|
	user_data_bags <<	search(:users, "groups:#{group}")
	user_data_bags.flatten!
	user_data_bags.each do |u|
		users << [ u['id'], u['ad_domain'] ] 
	end
end

users.uniq!

# the package name for EL5 is samba3x
if platform? ['redhat', 'centos' ] and 
	node['platform_version'].to_i == 5 
		pkg_name = "samba3x"
else
	pkg_name = "samba" 
end
	
# install the samba package
package pkg_name

# the kerberos client tools
package "krb5-workstation"

svcs = value_for_platform(
  ["ubuntu", "debian"] => { "default" => ["smbd", "nmbd"] },
  ["redhat", "centos", "fedora"] => { "default" => ["smb", "nmb"] },
  "arch" => { "default" => [ "samba" ] },
  "default" => ["smbd", "nmbd"]
)


svcs.each do |s|
  service s do
    pattern "smbd|nmbd" if node["platform"] =~ /^arch$/
		supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
  end
end

template node["samba"]["config"] do
  source "smb.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :shares => shares
  notifies :reload, resources(:service => svcs)
end

# kerberos configuration
template node["kerberos"]["config"] do
  source "krb5.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :reload, resources(:service => svcs)
end

template "/etc/samba/smbusers" do
  source "smbusers.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :users => users
  notifies :reload, resources(:service => svcs)
end

# join the active directory domain if not already a member
#execute "join_ad_domain" do
#	command	'net ads join -U${AD_RXVTU}%${AD_RXVTP}'
#	action :run
#	timeout 200
#	returns 0
#	not_if 'net ads status -U${AD_RXVTU}%${AD_RXVTP}'
#end
#

