#
# Cookbook Name:: acms
# Recipe:: install
#

acms = node['acms']

web_app "acms" do
  docroot acms['path']
end

remote_file "#{Chef::Config['file_cache_path']}/#{acms['version']}install.zip" do
  source acms['url']
  mode 0644
  not_if "test -f #{Chef::Config['file_cache_path']}/#{acms['version']}install.zip"
end

execute "Extracting and Building a-blog cms from Source" do
  command <<-EOS
    unzip -q #{acms['version']}install.zip
    mv #{acms['version']}install/ablogcms #{acms['path']}
  EOS
  cwd Chef::Config['file_cache_path']
  not_if "test -d #{acms['path']}"
  notifies :run, "bash[change mode]", :immediately
end

bash "change mode" do
  code <<-EOS
    chmod 666 config.server.php
    chmod 777 archives
    chmod 777 archives_rev
    chmod 777 media
    chmod 777 themes
    mv htaccess.txt .htaccess
  EOS
  cwd acms['path']
  action :nothing
end
