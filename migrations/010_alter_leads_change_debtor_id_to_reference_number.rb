# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    add_column :leads, :reference_number, String
    execute "UPDATE leads SET reference_number = debtor_id"
    drop_column :leads, :debtor_id
  end

  def down
    add_column :leads, :debtor_id, String
    execute "UPDATE leads SET debtor_id = reference_number"
    drop_column :leads, :reference_number
  end
end
