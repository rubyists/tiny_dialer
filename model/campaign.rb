module TinyDialer
  class Campaign < Sequel::Model
    one_to_many :lists
  end
end
