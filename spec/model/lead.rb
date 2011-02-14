require_relative '../db_helper'

describe 'TinyDialer::Lead' do

  before do
    @u = TinyDialer::Lead.create(:first_name => "jayson", :last_name => "vaughn", 
                            :phone => "817-690-7937", :status => "NEW", 
                            :debtor_id => '1234567', :zip => '75202')
    @tz = TinyDialer::Zip.create(:zip => '75202', :gmt => '-6.0', :state => 'TX')
    @state = TinyDialer::State.create(:state => 'TX', :start => "09:00", :stop => "21:00")
  end

  after do
    @u.destroy
    @tz.destroy
    @state.destroy
  end

  it 'should allow creation of a lead' do
    @u.id.should.not == nil
    @u.debtor_id.should == "1234567"
    @u.phone.should == "817-690-7937"
    @u.first_name.should == "jayson"
  end

  it 'should write lead status to a file in /tmp' do
    @u.update(:status => 'LTMC', :timestamp => Time.now)
    @u.write_status
    status_file = File.join(TinyDialer::ROOT, "results", "#{@u.debtor_id}.tsv")
    File.exists?(status_file).should == true
    file = File.open(status_file).each do |record|
      entry = record.strip.split("\t")
      entry[0].should == "1234567"
      entry[1].should == "LTMC"
      entry[2].should == "817-690-7937"
    end
  end

  it 'should format phone number so freeswitch can originate a call' do
    @u.phone_num.should == "8176907937"
  end

  it 'should return a timezone postgres can understand' do
    if Time.now.dst?
      @u.timezone.should == -6.0
    else
      @u.timezone.should == -6.0
    end
  end

  it 'should return a TinyDialer::Zip object' do
    zip_obj = @u.postal
    zip_obj.should.not == nil
    zip_obj.zip.should == '75202'
  end

  it 'should return a TinyDialer::State object' do
    state_obj = @u.state
    state_obj.should.not == nil
    state_obj.state.should == 'TX'
  end

  it 'should not allow a call to be placed twice in the same day' do
    @state.update(:start => '00:00', :stop => '23:59') # So the first spec will always pass
    @u.update(:timestamp => Time.now - 36000)
    @u.call?.should == true
    @u.update(:timestamp => Time.now, :status => 'ANSWERED')
    @u.call?.should != true
  end

end
