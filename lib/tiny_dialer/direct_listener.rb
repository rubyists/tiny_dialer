#!/usr/bin/ruby
require 'fsr'
require 'fsr/listener/outbound'
require_relative "../../app"

module TinyDialer
  class DirectListener < FSR::Listener::Outbound

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
        FSR::Log.info "*** Transferring #{exten} to #{queue}@#{@queue_server}:5080"
        bridge "{tcc_queue=#{queue}}sofia/internal/#{queue}@#{@queue_server}:5080"
      end
    end

  end
end

options = TinyDialer.options.direct_listener

FSR.start_oes!(
  TinyDialer::DirectListener,
  port: options.port,
  host: options.host,
  queue_server: options.queue_server
)
