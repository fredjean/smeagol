#
# Cookbook Name:: node
# Recipe:: default
#
#
#
DEFAULT_NODE_VERSION = "v0.4.11"

root = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "homebrew"))

require root + '/resources/homebrew'
require root + '/providers/homebrew'
require 'etc'

template "#{ENV['HOME']}/.npmrc" do
  mode   0700
  owner  ENV['USER']
  group  Etc.getgrgid(Process.gid).name
  source "dot.npmrc.erb"
  variables({ :home => ENV['HOME'] })
end

script "configuring nvm and node #{DEFAULT_NODE_VERSION}" do
  interpreter "bash"
  code <<-EOS
    source ~/.snuggie.profile
    cd #{ENV['HOME']}/Developer
    if [ ! -d ./.nvm ]; then
      git clone git://github.com/creationix/nvm.git .nvm >> ~/.snuggie/bootstrap.log
      source #{ENV['HOME']}/Developer/.nvm/nvm.sh        >> ~/.snuggie/bootstrap.log
      nvm install #{DEFAULT_NODE_VERSION}                >> ~/.snuggie/bootstrap.log
      nvm use #{DEFAULT_NODE_VERSION}                    >> ~/.snuggie/bootstrap.log
      curl http://npmjs.org/install.sh | sh              >> ~/.snuggie/bootstrap.log
    fi
  EOS
end
