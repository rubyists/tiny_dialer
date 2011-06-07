# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:lists) do
      primary_key :id
      String :name
      String :description
      Integer :start_time
      Integer :stop_time
      timestamp :timestamp, :default => :now.sql_function
      foreign_key :campaign_id, :campaigns
    end unless TinyDialer.db.tables.include? :lists
  end

  def down
    remove_table(:lists) if TinyDialer.db.tables.include? :lists
  end
end
