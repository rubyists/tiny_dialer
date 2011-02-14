require_relative '../db_helper'

describe 'TinyDialer::State' do

  before do
    @state = TinyDialer::State.create(:state => 'CA', :start => "09:00", :stop => "21:00")
  end

  after do
    @state.destroy
  end

  it 'should allow creation of a state' do
    @state.id.should.not == nil
    @state.state.should == "CA"
    @state.start.should == "09:00"
    @state.stop.should == "21:00"
  end

end
