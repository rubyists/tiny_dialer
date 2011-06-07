# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    alter_table :leads do
      add_foreign_key :list_id, :lists
      add_column :start_time, Integer
      add_column :stop_time, Integer
    end
  end

  def down
    alter_table :leads do
      drop_column :list_id
      drop_column :start_time
      drop_column :stop_time
    end
  end
end
