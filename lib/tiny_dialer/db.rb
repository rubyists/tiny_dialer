require 'sequel'
require 'logger'

require 'sequel'
require_relative "../../options"

module TinyDialer
  @db ||= nil

  def self.db
    @db ||= Sequel.connect(TinyDialer.options.db)
  end

  def self.db=(other)
    @db = Sequel.connect(other)
  end
end
