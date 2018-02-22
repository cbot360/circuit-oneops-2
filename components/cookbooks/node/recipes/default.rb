#
# Author:: Marius Ducea (marius@promethost.com)
# Cookbook Name:: nodejs
# Recipe:: default
#
# Copyright 2010-2012, Promet Solutions
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
# case node['platform_family']
  # when "debian"
  # # include_recipe "apt"
# end
require 'yaml'
include_recipe "node::ci_attr_to_node_attr"

if File.file?("/etc/oneops-tools-inventory.yml") && YAML.load_file("/etc/oneops-tools-inventory.yml").key?("nodejs_#{node['nodejs']['version']}")
  Chef::Log.info("On fast image and installing from file")
  include_recipe "node::install_from_file"
else
  include_recipe "node::install_from_#{node['nodejs']['install_method']}"
end

