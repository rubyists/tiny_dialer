# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:campaigns) do
      primary_key :id
      String :name
      String :description
      timestamp :timestamp, :default => :now.sql_function
    end unless TinyDialer.db.tables.include? :campaigns
  end

  def down
    remove_table(:campaigns) if TinyDialer.db.tables.include? :campaigns
  end
end
