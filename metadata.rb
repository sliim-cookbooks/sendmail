# -*- coding: utf-8 -*-
name 'sendmail'
maintainer 'Sliim'
maintainer_email 'sliim@mailoo.org'
license 'Apache-2.0'
description 'Installs/Configures sendmail'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
chef_version '>= 12.5' if respond_to?(:chef_version)
version '0.1.0'

supports 'debian', '> 7.0'

source_url 'https://github.com/sliim-cookbooks/sendmail' if
  respond_to?(:source_url)
issues_url 'https://github.com/sliim-cookbooks/sendmail/issues' if
  respond_to?(:issues_url)
