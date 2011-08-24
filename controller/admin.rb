module TinyDialer
  class AdminController < Controller
    map '/'

    provide(:json, engine: :None, type: 'application/json'){|action, object|
      object.to_json
    }

    def index
    end

    def upload_csv
      upload = request[:file]
      filename = [Time.now.xmlschema, upload[:filename]].join('_')
      path = File.join(ROOT, "csv", filename)
      clear_leads = request[:clear_leads]

      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'wb+'){|out| out.print(upload[:tempfile].read) }

      CsvScrubber.new(path, clear_leads).scrub_csv

      flash[:INFO] = "Loaded #{filename} : #{upload[:tempfile].size} bytes"
      redirect_referrer
    end

    def set_dialer_ratio
      TinyDialer.db[:dialer_pool].update ratio: request[:ratio].to_f
    end

    def stats
      settings = TinyDialer.db[:dialer_pool].order(:id).last
      queue = TinyDialer.options.dialer.transfer_queue
      ratio = settings[:ratio]

      sock = FSR::CommandSocket.new(:server => @host, :pass => @pass)
      current_dials = sock.channels.run.select{|ch| ch.dest != "19999" }

      ready_agents = if TinyDialer.options.direct_listener.tcc_root
                       TinyDialer::TCC_Helper.ready_agents(queue).map(&:name)
                     else
                       (0..settings[:dialer_max]).to_a
                     end

      max_dials = ENV['TD_Max_Dials'].to_i

      aim = [max_dials, (ready_agents.size - current_dials.size) * ratio].min

      return {
        ratio: ratio,
        aim: aim,
        current_dials: current_dials,
        dialer_status: dialer_status,
        ivr_status: ivr_status,
        ready_agents: ready_agents
      }
    end

    private

    def dialer_status
      dialer_status = `sv stat #{ENV['HOME']}/service/#{ENV['APP_DB']} 2>/dev/null`.split(':')[0]
    end

    def ivr_status
      ivr_status = `sv stat #{ENV['HOME']}/service/ivr 2>/dev/null`.split(':')[0]
    end
  end
end
