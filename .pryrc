#!/usr/bin/env ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'pathname'
$LOAD_PATH.unshift(Pathname.getwd.join('lib').to_s)
require 'eventful-ruby'

config_file = Pathname.new(Pathname.getwd.join('spec/config.yml'))
if config_file.exist?
  config = YAML.load_file(config_file.to_s)
  Eventful.api_key = config['api_key']
  Eventful.feed_key = config['feed_key']
else
  abort "Please setup a spec/config.yml file"
end

def reload!
  Dir["#{Dir.pwd}/lib/**/*.rb"].each { |f| load f }
end
