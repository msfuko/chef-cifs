#
# Cookbook Name:: cifs
# Recipe:: default
#
# Copyright 2013, Olivier Brisse
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Install required packages

case node['platform']
when 'ubuntu'
  if node['platform_version'].to_f <= 10.04
    pkg = 'smbfs'
  else
    pkg = 'cifs-utils'
  end
when 'debian'
  pkg = 'cifs-utils'
else
  Chef::Log.fatal("#{node['platform']} not supported")
end

package pkg

# Credentials files
if node['cifs']['encrypted_password_data_bag'].nil?
  bag = node['cifs']['password_data_bag']
  credentials = data_bag_item(bag, 'cifs') rescue nil
else
  bag = node['cifs']['encrypted_password_data_bag']
  credentials = Chef::EncryptedDataBagItem.load(bag, 'cifs') rescue nil
end


if credentials
  template node['cifs']['credential_file'] do
    source 'credentials.erb'
    owner 'root'
    group 'root'
    mode '0600'

    variables(
      :username => credentials['username'],
      :password => credentials['password'],
      :domain => credentials['domain']
    )
  end
else
  Chef::Log.warn("Data bag '#{bag}' not found, skipping credentials file")
end
