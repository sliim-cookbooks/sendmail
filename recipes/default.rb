# -*- coding: utf-8 -*-
#
# Cookbook Name:: sendmail
# Recipe:: default
#
# Copyright 2015, Sliim
#

node['sendmail']['packages'].each do |pkg|
  package pkg
end

authinfo = begin
             data_bag_item('sendmail', node['sendmail']['authinfo'])
           rescue
             nil
           end

if authinfo
  directory '/etc/mail/authinfo'
  template "/etc/mail/authinfo/#{authinfo['id']}-auth" do
    source 'auth.erb'
    variables authinfo: authinfo
  end

  execute "makemap hash #{authinfo['id']}-auth < #{authinfo['id']}-auth" do
    cwd '/etc/mail/authinfo'
  end

  template '/etc/mail/sendmail.mc' do
    source 'sendmail.mc.erb'
    variables id: authinfo['id'],
              host: authinfo['host'],
              port: authinfo['port']
    notifies :run, 'execute[make -C /etc/mail]'
  end

  execute 'make -C /etc/mail' do
    action :nothing
    notifies :restart, 'service[sendmail]'
  end
end

service 'sendmail' do
  action :nothing
end
