module TinyDialer
  class RecordsController < Controller
    map '/records'
    helper :paginate

    def search
      if request["date_start"].empty? or request["date_end"].empty?
        flash[:ERROR] = "Must put in a date range to search"
        redirect_referrer
      end

      date_start = request["date_start"] + " 00:00"
      date_end = request["date_end"] + " 23:59"
      phone_no = TinyDialerAdmin::PhoneNumber::parse(request["phone"]).to_s.strip unless request["phone"].empty? or request["phone"].nil?

      time_range = 'timestamp >= ? and timestamp <= ?'

      if phone_no
        @records= TinyDialer::Record.filter("phone = ? and (#{time_range})", phone_no, date_start, date_end).to_a
      else
        @records = TinyDialer::Record.filter("(#{time_range})", date_start, date_end).to_a
      end

      if @records.empty?
        flash[:ERROR] = "No records found with #{phone_no}"
        redirect_referrer
      end

      @records_paginated = paginate(@records, :limit => 25)
    end
  end
end
