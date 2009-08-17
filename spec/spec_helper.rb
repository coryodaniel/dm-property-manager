require 'rubygems'
require 'dm-core'
require 'lib/dm-property-manager'

gem 'rspec', '~>1.2'
require 'spec'

DataMapper.setup(:default, "sqlite3::memory:")