#!/usr/bin/ruby
require 'fsr'
require 'fsr/listener/outbound'
require_relative "../../app"

module TinyDialer
  class DirectListener < FSR::Listener::Outbound
    attr_reader :lead
    def initialize(args)
      @queue_server = args[:queue_server] || '127.0.0.1'
      super
    end

    def session_initiated
      exten = @session.headers[:caller_caller_id_number]
      queue = @session.headers[:variable_tcc_queue]
      unless queue
        speak("Good bye")
        close_connection
        return
      end
      FSR::Log.info "*** Answering incoming call from #{exten} for #{queue}"

      answer do
        id = session.headers[:variable_lead_id]
        @lead = Lead[:id => id]
        if lead
          direct_transfer(exten, queue)
        else
          FSR::Log.info "No lead found for id: #{id}, hanging up"
          hangup
          close_connection
        end
      end
    end

    def direct_transfer(extension, queue)
      # If the dialer is the same as the queue server, just use the callcenter app,
      # otherwise bridge the call to queue@queue_server
      if @queue_server =~ /^(?:#{TinyDialer.options.direct_listener.host}|127\.0\.0\.1)/
        FSR::Log.info "*** Transferring #{extension} to #{queue}"
        callcenter(queue) { close_connection }
      else
        FSR::Log.info "*** Transferring #{extension} to #{queue}@#{@queue_server}"
        bridge("{tcc_queue=#{queue}}sofia/internal/#{queue}@#{@queue_server}") { close_connection }
      end
    end

  end
end

options = TinyDialer.options.direct_listener

FSR.start_oes!(
  TinyDialer::DirectListener,
  port: options.port,
  host: options.host,
  queue_server: options.tcc_server
)
