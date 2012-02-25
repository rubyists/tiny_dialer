require_relative '../db_helper'

describe 'TinyDialer::LeadScrubber' do
  example = File.join(TinyDialer::ROOT, "spec", "csv_test.csv")

  it 'reads leads from csv' do
    leads = TinyDialer::LeadScrubber.each_lead(example).to_a
    leads.first.to_hash.should == {
      "REFNUMBER"=>"1819039",
      "NAME1"=>"Vanderpoel, Tj",
      "NAME2"=>"",
      "INIT-BALANCE"=>"320.0",
      "BALANCE"=>"320.0",
      "RES-PHONE"=>"4719395828",
      "STATE"=>"CA",
      "ZIP"=>"95202"
    }
    leads.size.should == 13
  end

  it 'loads leads from csv into the db' do
    TinyDialer::Lead.destroy
    TinyDialer::LeadScrubber.import_leads(example)
    TinyDialer::Lead.count.should == 13
    TinyDialer::Lead[
      first_name: 'Tj',
      last_name: 'Vanderpoel',
      reference_number: '1819039',
      balance: '320.0',
      state: 'CA',
      zip: '95202',
      phone: '4719395828',
    ].should.not.be.nil
  end
end
