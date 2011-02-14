require_relative '../db_helper'

describe 'TinyDialer::CsvScrubber' do

  after do
    TinyDialer::Lead.all.each {|x| x.destroy}
  end

  it 'be able to read a csv and load into the DB' do
    scrubber = TinyDialer::CsvScrubber.new(File.join(TinyDialer::ROOT, "spec", "csv_test.csv"))
    scrubber.read_csv.should == 5
    scrubber.load_db
    TinyDialer::Lead.all.size.should == 4
  end

end
