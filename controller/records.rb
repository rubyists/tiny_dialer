module TinyDialer
  class RecordsController < Controller
    map '/records'
    helper :paginate

    def search
      request.to_ivs(:date_start, :date_end, :phone)

      if @date_start && @date_end
        date_start, date_end = "#{@date_start} 00:00", "#{@date_end} 23:59"
      else
        flash[:records_search_error] = "Must put in a date range to search"
        redirect_referrer
      end

      phone_no = TinyDialerAdmin::PhoneNumber::parse(@phone).to_s.strip if @phone
      time_range = 'timestamp >= ? and timestamp <= ?'

      if phone_no
        @records= Record.filter("phone = ? and (#{time_range})", phone_no, date_start, date_end).to_a
      else
        @records = Record.filter("(#{time_range})", date_start, date_end).to_a
      end

      if @records.empty?
        flash[:records_search_error] = "No records found with #{phone_no}"
        redirect_referrer
      end

      @records_paginated = paginate(@records, :limit => 25)
    end
  end
end
