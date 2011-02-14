module TinyDialer
  class AdminController < Controller
    map '/'

    def index
      @status = `sv stat #{ENV['HOME']}/service/#{ENV['APP_DB']}`.split(':')[0]
      @ivr_status = `sv stat #{ENV['HOME']}/service/ivr`.split(':')[0]
      @dialer_pool = TinyDialer.db[:dialer_pool].order(:id).last[:dialer_max]
    end

    def upload_csv
      upload = request[:file]
      filename = [Time.now.xmlschema, upload[:filename]].join('_')
      path = File.join(ROOT, "csv", filename)

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb+'){|out| out.print(upload[:tempfile].read) }

      CsvScrubber.new(path).scrub_csv

      flash[:INFO] = "Loaded #{filename} : #{upload[:tempfile].size} bytes"
      redirect_referrer
    end

    def set_dialer_max
      TinyDialer.db[:dialer_pool].update dialer_max: request[:max].to_i
    end

    def start_dialer
      dialer_pool = request[:dialer_pool]

      if dialer_pool.empty?
        flash[:INFO] = "Must input Number of Dialers to run!"
        redirect_referrer
      end

      TinyDialer.db[:dialer_pool].update dialer_max: 1

      if sv_u("#{ENV['HOME']}/service/#{ENV['APP_DB']}")
        flash[:INFO] = "Starting Dialer with #{dialer_pool} workers"
      else
        flash[:WARN] = "Failed to start the Dialer with #{dialer_pool} workers"
      end
      redirect_referrer
    end

    def start_ivr
      if sv_u("#{ENV['HOME']}/service/ivr")
        flash[:INFO] = "Started The IVR Listener"
      else
        flash[:WARN] = "Failed to start the IVR Listener"
      end
      redirect_referrer
    end

    def stop_ivr
      if sv_d("#{ENV['HOME']}/service/ivr")
        flash[:INFO] = "Stopped The IVR Listener"
      else
        flash[:WARN] = "Failed to stop The IVR Listener"
      end
      redirect_referrer
    end

    def stop_dialer
      if sv_d("#{ENV['HOME']}/service/#{ENV['APP_DB']}")
        flash[:INFO] = "Stopped The Dialer"
      else
        flash[:WARN] = "Failed to stop the Dialer"
      end
      redirect_referrer
    end

    private

    def sv_u(path)
      system('sv', 'u', path)
    end

    def sv_d(path)
      system('sv', 'd', path)
    end
  end
end
