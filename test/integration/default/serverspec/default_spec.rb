# -*- coding: utf-8 -*-

require 'spec_helper'

describe file '/etc/mail/authinfo/kitchen-auth' do
  it { should_not be_file }
end

describe file '/etc/mail/authinfo/kitchen-auth.db' do
  it { should be_file }
end

describe file '/etc/mail/sendmail.mc' do
  it { should be_file }
end
