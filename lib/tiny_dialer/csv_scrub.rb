require_relative '../tiny_dialer'
require 'csv'
require 'name_parse'

module TinyDialer
  class CsvScrubber
    attr_reader :path, :db, :records

    def initialize(path)
      @path = path
      @db = TinyDialer.db
    end

    def read_csv
      @records ||= CSV.read(path)
      Log.info "Records loaded: #{records.size}"
    end

    def load_db
      records.each_with_index do |record, index|
        next if index == 0
        Log.info "Loading record ##{index} #{record}"
        n = NameParse[record[1]]
        TinyDialer::Lead.create(:debtor_id => record[0], :first_name => n.first, :last_name => n.last, :suffix => n.suffix, :prefix => n.prefix, :phone => record[5], :balance => record[4], :status => 'NEW', :zip => record[7])
      end
      Log.info "DB loaded"
    end

    def clear_previous_leads
      TinyDialer::Lead.all.each {|x| x.destroy}
      Log.info "Cleared Leads from DB"
    end

    def scrub_csv
      clear_previous_leads
      read_csv
      load_db
    end

  end
end
