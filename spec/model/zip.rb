require_relative '../db_helper'

describe 'TinyDialer::Zip' do

  before do
    @zip = TinyDialer::Zip.create(:zip => '75007', :state => 'TX', :gmt => '-6.0')
  end

  after do
    @zip.destroy
  end

  it 'should allow creation of a zip' do
    @zip.id.should.not == nil
    @zip.zip.should == "75007"
    @zip.state.should == "TX"
    @zip.gmt.should == "-6.0"
  end

end
