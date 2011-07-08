#
# Cookbook Name:: homebrew
# Recipe:: dbs
#

root = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require root + '/resources/homebrew'
require root + '/providers/homebrew'

%w(tig ack coreutils imagemagick sqlite wget hub fortune proctools markdown ctags-exuberant gpgme).each do |pkg|
  homebrew pkg
end

