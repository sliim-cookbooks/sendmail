# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'sendmail::default' do
  before do
    stub_data_bag_item('sendmail', 'default').and_return(nil)
  end

  let(:subject) do
    ChefSpec::SoloRunner.new(
      platform: 'debian', version: '9.3').converge(described_recipe)
  end

  %w(sendmail sendmail-bin mailutils).each do |pkg|
    it "installs package[#{pkg}]" do
      expect(subject).to install_package(pkg)
    end
  end

  context 'with data bags' do
    let(:subject) do
      stub_data_bag_item(:sendmail, 'test').and_return(
        'id' => 'test',
        'user' => 'root',
        'account' => 'test@foobar.baz',
        'password' => 'encrypted-passwd',
        'host' => 'smtp.foobar.baz',
        'port' => 1337)

      ChefSpec::SoloRunner.new(platform: 'debian', version: '9.3') do |node|
        node.override['sendmail']['authinfo'] = 'test'
      end.converge(described_recipe)
    end

    it 'creates directory[/etc/mail/authinfo]' do
      expect(subject).to create_directory('/etc/mail/authinfo')
    end

    it 'creates template[/etc/mail/authinfo/test-auth]' do
      expect(subject).to create_template('/etc/mail/authinfo/test-auth')
        .with(source: 'auth.erb')
    end

    it 'runs execute[makemap hash test-auth < test-auth]' do
      expect(subject).to run_execute('makemap hash test-auth < test-auth')
        .with(cwd: '/etc/mail/authinfo')
    end

    it 'creates template[/etc/mail/sendmail.mc]' do
      expect(subject).to create_template('/etc/mail/sendmail.mc')
        .with(source: 'sendmail.mc.erb')
    end
  end
end
