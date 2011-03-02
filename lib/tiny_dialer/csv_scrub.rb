require_relative '../tiny_dialer'
require 'csv'
require 'name_parse'

module TinyDialer
  class CsvScrubber
    attr_reader :path, :db, :records, :clear_leads

    def initialize(path, clear_leads = false)
      @path = path
      @db = TinyDialer.db
      @clear_leads = clear_leads
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
        TinyDialer::Lead.create(:reference_number => record[0], :first_name => n.first, :last_name => n.last, :suffix => n.suffix, :prefix => n.prefix, :phone => record[5], :balance => record[4], :status => 'NEW', :zip => record[7], :state => record[6])
      end
      Log.info "DB loaded"
    end

    def clear_previous_leads
      TinyDialer::Lead.all.each {|x| x.destroy}
      Log.info "Cleared Leads from DB"
    end

    def scrub_csv
      if clear_leads
      	 clear_previous_leads
      end
      read_csv
      load_db
    end

  end
end
