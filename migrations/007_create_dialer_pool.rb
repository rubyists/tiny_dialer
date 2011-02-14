# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:dialer_pool) do
      primary_key :id
      Integer :dialer_max
      timestamp :timestamp
    end unless TinyDialer.db.tables.include? :dialer_pool
  end

  def down
    remove_table(:dialer_pool) if TinyDialer.db.tables.include? :dialer_pool
  end
end
