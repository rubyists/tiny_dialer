require_relative '../tiny_dialer'
require 'csv'
require 'name_parse'

module TinyDialer
  module LeadScrubber
    MAP = {
      balance: 'BALANCE',
      fullname: 'NAME1',
      phone: 'RES-PHONE',
      reference_number: 'REFNUMBER',
      state: 'STATE',
      zip: 'ZIP',
    }

    module_function

    def each_lead(res)
      return to_enum(__method__, res) unless block_given?

      CSV.open res, headers: true do |csv|
        csv.each do |entry|
          yield(entry)
        end
      end
    end

    def import_leads(res)
      each_lead res do |lead|
        hash = lead.to_hash
        name = NameParse[hash.fetch('NAME1')]
        TinyDialer::Lead.create(
          first_name: name.first,
          last_name: name.last,
          suffix: name.suffix,
          prefix: name.prefix,
          balance: hash.fetch('INIT-BALANCE'),
          phone: hash.fetch('RES-PHONE'),
          reference_number: hash.fetch('REFNUMBER'),
          state: hash.fetch('STATE'),
          status: 'NEW',
          zip: hash.fetch('ZIP'),
        )
      end
    end
  end
end
