#!/usr/bin/ruby
require 'fsr'
require 'fsr/listener/outbound'
require 'fsr/listener/inbound'
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
          tell_popper(exten, lead)
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

    def tell_popper(exten, lead)
      return unless popper = POPPER[exten]
      popper.popup(lead)
    end
  end

  class DialEventListener < FSR::Listener::Inbound
    def before_session
      add_event :CUSTOM, 'callcenter::info', &method(:callcenter_info)
      add_event :BACKGROUND_JOB, &method(:background_job)
    end

    def callcenter_info(event)
      content = event.content

      case content[:cc_action]
      when 'bridge-agent-start'
        bridge_agent_start(content)
      end
    end

    def background_job(event)
      FSR::Log.debug "<<< Bridge Agent Start >>>"
      FSR::Log.debug event
    end

    def bridge_agent_start(content)
      FSR::Log.debug "!!! Bridge Agent Start !!!"
      FSR::Log.debug content
    end
  end

  module CubsPopper
    POPPERS = {}

    def receive_data(data)
      case data
      when /^extension: (\d+)/
        @extension = $1
        FSR::Log.info "Register Cubs Popper for #{@extension}"
        POPPERS[@extension] = self
      end
    end

    def unbind
      FSR::Log.info "Disconnect Cubs Popper for #{@extension}"
      POPPERS.delete @extension
    end

    def popup(lead)
      send_data "(#{lead})"
    end
  end
end

options = TinyDialer.options.direct_listener

EventMachine::run do
  FSR::Log.info "Start CUBS Popper Server on 0.0.0.0:9186"
  EventMachine::start_server "0.0.0.0", 9186, TinyDialer::CubsPopper

  FSR::Log.info "Connecting to #{options.host} #{options.port}"
  EventMachine::connect options.host, options.port, TinyDialer::DialEventListener, host: options.host, port: options.port
  EventMachine::connect options.host, options.port, TinyDialer::DirectListener, host: options.host, port: options.port, queue_server: options.tcc_server
end
