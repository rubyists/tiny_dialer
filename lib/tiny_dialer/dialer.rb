require_relative '../tiny_dialer'
require 'fsr'

module TinyDialer
  class Dialer
    attr_accessor :server, :auth
    attr_reader :hopper

    def initialize(args = {})
      FSR.load_all_commands
      @server = args[:host] || '127.0.0.1' # Freeswitch server to connect to
      @proxy_server_fmt = args[:proxy_server_fmt] || 'loopback/%s/default/XML'
      @auth = args[:auth] || args[:pass] || 'ClueCon' # Freeswitch auth
      @es = FSR::CommandSocket.new(:server => @server, :auth => @auth) # FSR Command Socket instance
      @hopper = args[:hopper]
    end

    def es
      yield(@es)
    rescue Errno::EPIPE
      @es = FSR::CommandSocket.new(:server => @server, :auth => @auth)
      retry
    end


    def dial
      if lead = @hopper.next
        TinyDialer::Log.debug "Dialing #{lead}"
        dial_next(lead)
        true
      else
        TinyDialer::Log.info "Hopper is empty, no one to dial"
        false
      end
    end

    private

    def caller_id(number)
      if global = TinyDialer.options.dialer.caller_id
        return global
      end
      number
    end

    def dial_next(lead)
      if lead.call?
        lead.update(:status => 'DIALING', :timestamp => Time.now) # update lead status to dialing
        lead.update(:status => 'DIALING', :timestamp => Time.now) # update lead status to dialing
        queue = lead.queue
        response = es{|e| e.originate(:target => "{tcc_queue=#{queue}}[origination_caller_id_number=#{caller_id(lead.phone_num)}]#{@proxy_server_fmt % lead.phone_num}",
                                :endpoint => FSR::App::Transfer.new('direct_transfer XML default'),
                                :target_options => {:lead_id => lead.id}).run }
        Log.info "Calling #{lead.reference_number}: #{lead.first_name} #{lead.last_name} at #{lead.phone}."
      else
        Log.info "Not Calling #{lead.reference_number}: #{lead.first_name} #{lead.last_name}."
      end
    end

  end

end
