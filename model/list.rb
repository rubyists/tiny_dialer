module TinyDialer
  class List < Sequel::Model
    many_to_one :campaign
    one_to_many :leads
  end
end
