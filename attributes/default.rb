# -*- coding: utf-8 -*-
#
# Cookbook Name:: sendmail
# Attributes:: default
#
# Copyright 2015, Sliim
#

default['sendmail']['packages'] = %w(sendmail sendmail-bin mailutils)
default['sendmail']['authinfo'] = 'default'
