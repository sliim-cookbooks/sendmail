# -*- coding: utf-8 -*-

require_relative 'spec_helper'

describe 'sendmail::default' do
  subject { ChefSpec::SoloRunner.new.converge(described_recipe) }

  %w(sendmail sendmail-bin mailutils).each do |pkg|
    it "installs package[#{pkg}]" do
      expect(subject).to install_package(pkg)
    end
  end

  context 'with data bags' do
    let(:subject) do
      ChefSpec::ServerRunner.new do |node|
        node.set['sendmail']['authinfo'] = 'test'
      end.converge(described_recipe)
    end
    before do
      allow(Chef::EncryptedDataBagItem).to receive(:load_secret)
        .and_return('stub_secret')
      allow(Chef::EncryptedDataBagItem).to receive(:load)
        .with('sendmail', 'test', 'stub_secret')
        .and_return('id' => 'test',
                    'user' => 'root',
                    'account' => 'test@foobar.baz',
                    'password' => 'encrypted-passwd',
                    'host' => 'smtp.foobar.baz',
                    'port' => 1337)
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
