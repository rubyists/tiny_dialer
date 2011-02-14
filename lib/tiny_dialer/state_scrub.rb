require_relative '../tiny_dialer'

module TinyDialer
  class StateScrubber
    attr_reader :path, :db, :records

    def initialize(path = File.join(TinyDialer::ROOT, "doc", "US_states.txt"))
      @path = path
      @db = TinyDialer.db
    end

    def read_states
      @records ||= File.open(path)
    end

    def load_db
      records.each do |record|
        state = record
        TinyDialer::State.create(:state => record.strip.to_s) 
      end
    end

  end
end
