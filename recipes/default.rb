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

authinfo = nil

unless Chef::Config[:solo]
  ssl_secret = Chef::EncryptedDataBagItem.load_secret(
    Chef::Config['encrypted_data_bag_secret'])
  begin
    authinfo = Chef::EncryptedDataBagItem.load('sendmail',
                                               node['sendmail']['authinfo'],
                                               ssl_secret)
  rescue Net::HTTPServerException
    Chef::Log.warn(
      "No data bag found for authinfo `#{node['sendmail']['authinfo']}`.")
  end
end

unless authinfo.nil?
  directory '/etc/mail/authinfo'
  template "/etc/mail/authinfo/#{authinfo['id']}-auth" do
    source 'auth.erb'
    variables authinfo: authinfo
  end

  execute "makemap hash #{authinfo['id']}-auth < #{authinfo['id']}-auth" do
    cwd '/etc/mail/authinfo'
    notifies :delete, "file[/etc/mail/authinfo/#{authinfo['id']}-auth]"
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
    notifies :reload, 'service[sendmail]'
  end

  file "/etc/mail/authinfo/#{authinfo['id']}-auth" do
    action :nothing
  end
end

service 'sendmail' do
  action :nothing
end
