require_relative '../db_helper'

describe 'TinyDialer::StateScrubber' do

  after do
    TinyDialer::State.all.each {|x| x.destroy}
  end

  it 'be able to read US states and load into the DB' do
    scrubber = TinyDialer::StateScrubber.new
    scrubber.read_states
    scrubber.load_db
    TinyDialer::State.all.size.should == 51
  end

end
