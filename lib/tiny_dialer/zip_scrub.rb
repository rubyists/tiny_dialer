require_relative '../tiny_dialer'

module TinyDialer
  class ZipScrubber
    attr_reader :path, :db, :records

    def initialize(path = File.join(TinyDialer::ROOT, "doc", "GMT_USA_zip.txt"))
      @path = path
      @db = TinyDialer.db
    end

    def read_zip
      @records ||= File.open(path)
    end

    def load_db
      records.each do |record|
        entry = record.strip.split("\t")
        TinyDialer::Zip.create(:zip => entry[0], :state => entry[1], :gmt => entry[2]) 
      end
    end
  end
end
