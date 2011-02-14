# Copyright (c) 2008-2009 The Rubyists, LLC (effortless systems) <rubyists@rubyists.com>
# Distributed under the terms of the MIT license.
# The full text can be found in the LICENSE file included with this software
#
Class.new Sequel::Migration do
  def up
    create_table(:leads) do
      primary_key :id
      String :first_name
      String :last_name
      String :suffix
      String :prefix
      String :address
      String :address_two
      String :address_three
      String :city
      String :state
      String :country
      String :zip
      String :phone
      String :alt_phone
      String :status
      String :balance
      String :debtor_id
      timestamp :timestamp
    end unless TinyDialer.db.tables.include? :leads
  end

  def down
    remove_table(:leads) if TinyDialer.db.tables.include? :leads
  end
end
