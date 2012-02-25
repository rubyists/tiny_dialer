require 'csv'
#require 'tzinfo'

class TinyDialer::Lead < Sequel::Model
  set_dataset :leads

  def phone_num
    phone.gsub('-', '') # Return phone number without hyphens, i.e. "-"
  end

  def write_status
    File.open write_status_path, 'wb+', 0664 do |f|
      f.puts [reference_number, status, phone, timestamp.strftime("%Y-%m-%d\t%H:%M"), 'BD_IC'].join("\t")
    end
  end

  def write_status_path
    "#{TinyDialer::ROOT}/results/#{reference_number}.tsv"
  end

  def postal
    @zip ||= TinyDialer::Zip[:zip => zip[0..4]] if zip
    @zip
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
    if reason = rejection_reason
      TinyDialer::Log.info "Rejected #{phone}: #{reason}"
      return false
    end

    # Make sure (now, now) overlaps (start, stop)
    now = (Time.now.utc + (3600*(timezone)).to_i).strftime('%H:%M')
    if TinyDialer.db.fetch("select ('#{now}'::text::time, '#{now}'::text::time) OVERLAPS ('#{state.start}'::text::time, '#{state.stop}'::text::time)").first[:overlaps]
      return true
    else
      TinyDialer::Log.info "Rejected #{phone}: Outside of calling times #{state.start} and #{state.stop}"
      return false
    end
  rescue => e
    TinyDialer::Log.error e
    false
  end

  def dnc?
    TinyDialer::Dnc[number: phone_num]
  end

  def called_today?
    timestamp && Date.today == timestamp.to_date
  rescue => e
    TinyDialer::Log.error e
    false
  end

  private

  def rejection_reason
    return :no_zip unless zip
    return :no_state unless state
    return :called_today if called_today?
    return :do_not_call if dnc?
    false
  end

  def before_create
    self[:created_at] = DateTime.now
    self[:status] ||= "NEW"
  end
end
