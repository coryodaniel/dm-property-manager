#!/usr/bin/env ruby

require 'rubygems'
require 'rake'
require 'rake/clean'

require 'spec/rake/spectask'
require "spec"
require 'rake/rdoctask'
require 'rake/gempackagetask'

require "lib/dm-property-manager"
NAME    = 'dm-property-manager'

CLEAN.include ["**/.*.sw?", "pkg", "lib/*.bundle", "*.gem", "doc/rdoc", ".config", "coverage", "cache"]

Dir['./tasks/**/*.rake'].each{|t| load t}