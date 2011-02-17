require_relative '../tiny_dialer'
require 'fsr'

module TinyDialer
  class Dialer
    attr_accessor :server, :auth
    attr_reader :hopper

    def initialize(args = {})
      FSR.load_all_commands
      @server = args[:host] || '127.0.0.1' # Freeswitch server to connect to
      @proxy_server = args[:proxy_server] || @server
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
      return unless lead = @hopper.next
      dial_next(lead)
      true
    end

    private

    def dial_next(lead)
      if lead.call?
        lead.update(:status => 'DIALING', :timestamp => Time.now) # update lead status to dialing
        lead.update(:status => 'DIALING', :timestamp => Time.now) # update lead status to dialing
        queue = lead.queue
        response = es{|e| e.originate(:target => "{tcc_queue=#{queue}}[origination_caller_id_number=8887961510]sofia/external/1#{lead.phone_num}@#{@proxy_server}",
                                #:endpoint => "callcenter sales",
                                :endpoint => FSR::App::Transfer.new('direct_transfer XML default'),
                                :target_options => {:lead_id => lead.id}).run }
        Log.info "Calling #{lead.debtor_id}: #{lead.first_name} #{lead.last_name} at #{lead.phone}."
      else
        Log.info "Not Calling #{lead.debtor_id}: #{lead.first_name} #{lead.last_name}."
      end
    end

  end

end
