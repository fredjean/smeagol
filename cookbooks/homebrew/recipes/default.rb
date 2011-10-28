#
# Cookbook Name:: homebrew
# Recipe:: homebrew
#

HOMEBREW_DEFAULT_SHA1 = '05209f7c75f693edf23d992b5a00409520d36de2'

root = File.expand_path(File.join(File.dirname(__FILE__), ".."))

require root + '/resources/homebrew'
require root + '/providers/homebrew'
require 'etc'

directory "#{ENV['HOME']}/Developer" do
  action :create
end

directory "#{ENV['HOME']}/Developer/tmp" do
  action :create
end

directory "#{ENV['HOME']}/.snuggie" do
  action :create
end

execute "download homebrew installer" do
  command "/usr/bin/curl -sfL http://github.com/mxcl/homebrew/tarball/master | /usr/bin/tar xz -m --strip 1"
  cwd     "#{ENV['HOME']}/Developer"
  not_if  "test -e ~/Developer/bin/brew"
end

script "cleaning legacy artifacts" do
  interpreter "bash"
  code <<-EOS
  if [ -f ~/.cider.profile ]; then
    rm ~/.cider.profile
  fi
  if [ -f ~/.cider.profile.custom ]; then
    mv ~/.cider.profile.custom ~/.snuggie.profile.custom
  fi
  EOS
end

template "#{ENV['HOME']}/.snuggie.profile" do
  mode   0700
  owner  ENV['USER']
  group  Etc.getgrgid(Process.gid).name
  source "dot.profile.erb"
  variables({ :home => ENV['HOME'] })
end

%w(bash_profile bashrc zshrc).each do |config_file|
  execute "include snuggie environment into defaults for ~/.#{config_file}" do
    command "if [ -f ~/.#{config_file} ]; then echo 'source ~/.snuggie.profile' >> ~/.#{config_file}; fi"
    not_if  "grep -q 'snuggie.profile' ~/.#{config_file}"
  end
end

execute "setup snuggie profile sourcing in ~/.profile" do
  command "echo 'source ~/.snuggie.profile' >> ~/.profile"
  not_if  "grep -q 'snuggie.profile' ~/.profile"
end

homebrew "git"

script "ensure the git remote is installed" do
  interpreter "bash"
  code <<-EOS
    source ~/.snuggie.profile
    cd ~/Developer
    if [ ! -d ./.git ]; then
      git init
      git remote add origin git://github.com/mxcl/homebrew.git
      git fetch -q origin
      git reset --hard origin/master
    fi
  EOS
end

script "updating homebrew from github" do
  interpreter "bash"
  code <<-EOS
    source ~/.snuggie.profile
    PATH=#{ENV['HOME']}/Developer/bin:$PATH; export PATH
    (cd ~/Developer && git fetch -q origin && git reset --hard #{ENV['CINDERELLA_RELEASE'] || HOMEBREW_DEFAULT_SHA1}) >> ~/.snuggie/brew.log 2>&1
  EOS
end

homebrew "nginx"
homebrew "bash-completion"
# homebrew "solr"
