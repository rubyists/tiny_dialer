# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software

desc "migrate to latest version of db"
task :migrate do
  require File.expand_path("../../lib/tiny_dialer", __FILE__)
  require TinyDialer::LIBROOT/:tiny_dialer/:db
  require 'sequel/extensions/migration'

  raise "No DB found" unless TinyDialer.db


  Sequel::Migrator.apply(TinyDialer.db, TinyDialer::MIGRATION_ROOT)
end
