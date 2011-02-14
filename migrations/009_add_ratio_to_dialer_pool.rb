# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table(:dialer_pool) do
      add_column :ratio, Float
      add_column :name, String
    end if TinyDialer.db.tables.include? :dialer_pool
  end

  def down
    alter_table(:dialer_pool) do
      drop_column :ratio
      drop_column :name
    end if TinyDialer.db.tables.include? :dialer_pool
  end
end
