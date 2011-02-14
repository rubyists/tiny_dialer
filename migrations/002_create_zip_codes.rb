# Copyright (c) 2010-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:zips) do
      primary_key :id
      String :zip, :length => 5
      String :state, :length => 2
      String :gmt
    end unless TinyDialer.db.tables.include? :zips
  end

  def down
    remove_table(:zips) if TinyDialer.db.tables.include? :zips
  end
end
