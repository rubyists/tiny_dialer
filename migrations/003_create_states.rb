# Copyright (c) 2010-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:states) do
      primary_key :id
      String :state, :length => 2
      String :start
      String :stop
    end unless TinyDialer.db.tables.include? :states
  end

  def down
    remove_table(:states) if TinyDialer.db.tables.include? :states
  end
end
