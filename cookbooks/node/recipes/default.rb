#
# Cookbook Name:: node
# Recipe:: default
#
#
root = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "homebrew"))

require root + '/resources/homebrew'
require root + '/providers/homebrew'
require 'etc'

script "configuring nvm" do
  interpreter "bash"
  code <<-EOS
    source ~/.snuggie.profile
    cd #{ENV['HOME']}/Developer
    if [ ! -d ./.nvm ]; then
      git clone git://github.com/creationix/nvm.git .nvm >> ~/.snuggie/bootstrap.log
      source #{ENV['HOME']}/Developer/.nvm/nvm.sh        >> ~/.snuggie/bootstrap.log
      nvm install v0.4.1                                 >> ~/.snuggie/bootstrap.log
      nvm use v0.4.1                                     >> ~/.snuggie/bootstrap.log
      curl http://npmjs.org/install.sh | sh              >> ~/.snuggie/bootstrap.log
    fi
  EOS
end
