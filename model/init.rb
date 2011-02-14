require 'sequel'
require 'logger'

require_relative '../lib/tiny_dialer'
require TinyDialer::LIBROOT/:tiny_dialer/:db
raise "No DB available" unless TinyDialer.db

require_relative 'lead'
require_relative 'zip'
require_relative 'state'
require_relative 'record'
require_relative 'dnc'
