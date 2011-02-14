require 'csv'

class TinyDialer::Zip < Sequel::Model(TinyDialer.db[:zips])
end
