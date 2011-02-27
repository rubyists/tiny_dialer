require 'csv'
#require 'tzinfo'

class TinyDialer::Lead < Sequel::Model
  set_dataset :leads
  attr_reader :rej

  def phone_num
    phone.gsub('-', '') # Return phone number without hyphens, i.e. "-"
  end

  def write_status
    File.open(File.join(TinyDialer::ROOT, "results", "#{self.debtor_id}.tsv"), 'wb', 0664) do |f|
      f.puts "#{self.debtor_id}\t#{self.status}\t#{self.phone}\t#{self.timestamp.year}-#{self.timestamp.month}-#{self.timestamp.day}\t#{self.timestamp.hour}:#{self.timestamp.min}\tBD_IC"
    end
  end

  def postal
    @zip ||= TinyDialer::Zip[:zip => zip[0..4]] if zip
  end

  def state
    return unless postal && postal.state
    @state ||= TinyDialer::State[:state => postal.state]
  end

  def timezone
    return 5 unless zip && zip.size >= 5
    postal.gmt.to_f
  end

  # Time::mktime/Time::utc/Time::local/Time::gmt are NOT working for this,
  # don't even try it.
  #
  # Resorted to using postgres for the time comparison, because it Just Works
  def call?
    if rejection_reason
      TinyDialer::Log.info "Rejected #{phone}: #{rejection_reason}"
      return
    end
    # Make sure (now, now) overlaps (start, stop)
    now = (Time.now.utc + (3600*(timezone)).to_i).strftime('%H:%M')
    TinyDialer.db.fetch("select ('#{now}'::text::time, '#{now}'::text::time) OVERLAPS ('#{state.start}'::text::time, '#{state.stop}'::text::time)").first[:overlaps]
  rescue => e
    TinyDialer::Log.error e
    return
  end

  def dnc?
    TinyDialer::Dnc[:number => self.phone_num]
  end

  def called_today?
    return unless timestamp
    begin
      Time.now.to_date == timestamp.to_date
    rescue => e
      TinyDialer::Log.error e
      return
    end
  end

  private
  def rejection_reason
    return @rej = :no_zip unless zip
    return @rej = :no_state unless state
    #return @rej = :called_today if called_today?
    return @rej = :do_not_call if dnc?
    @rej = false
  end

  def before_create
    self[:created_at] = DateTime.now
    self[:status] ||= "NEW"
  end

end
