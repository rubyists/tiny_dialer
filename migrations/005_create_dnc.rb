# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:dncs) do
      primary_key :id
      String :number
      String :description
      timestamp :timestamp
    end unless TinyDialer.db.tables.include? :dncs
  end

  def down
    remove_table(:dncs) if TinyDialer.db.tables.include? :dncs
  end
end
