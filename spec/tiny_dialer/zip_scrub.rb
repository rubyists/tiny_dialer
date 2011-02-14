require_relative '../db_helper'

describe 'TinyDialer::ZipScrubber' do

  after do
    TinyDialer::Zip.all.each {|x| x.destroy}
  end

  it 'be able to read zip codes and load into the DB' do
    scrubber = TinyDialer::ZipScrubber.new(File.join(TinyDialer::ROOT, "spec", "zip_test.tsv"))
    scrubber.read_zip
    scrubber.load_db
    TinyDialer::Zip.all.size.should == 3
  end

end
