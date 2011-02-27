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

  class DialEventListener < FSR::Listener::Inbound
    def before_session
      @queue_starts = {}

      add_event(:CUSTOM, 'callcenter::info', &method(:callcenter_info))
      add_event(:BACKGROUND_JOB, &method(:background_job))
    end

    def background_job(event)
      FSR::Log.info "<<< Background Job >>>"
      FSR::Log.info content = event.content

      if content[:job_command] == 'originate'
        if lead_id = content[:job_command_arg].to_s[/lead_id%3D(\d+)/, 1]
          FSR::Log.info "Lead ID: #{lead_id}"
        end
      end
    end

    def callcenter_info(event)
      content = event.content

      case content[:cc_action]
      when 'member-queue-start'
        member_queue_start(content)
      when 'bridge-agent-start'
        bridge_agent_start(content)
      end
    end

    # lead enters queue
    def member_queue_start(content)
      uuid, lead = content.values_at(:cc_caller_uuid, :variable_lead_id)
      @queue_starts[uuid] = lead
    end

    # agent accepts lead
    # FIXME: use Account to split agent
    def bridge_agent_start(content)
      uuid = content[:cc_caller_uuid]

      unless lead_id = @queue_starts[uuid]
        FSR::Log.info "<<< OMG, no lead found for #{uuid} >>>"
        return
      else
        FSR::Log.info "<<< Lead id is #{lead_id} >>>"
        lead = TinyDialer::Lead[lead_id]
        reference_number = lead.reference_number
      end

      agent_name = content[:cc_agent] # 1012-Paul_McCartney
      agent_ext = agent_name.split('-', 2).first
      tell_popper(agent_ext, reference_number)
    end

    def tell_popper(exten, reference_number)
      return unless popper = CubsPopper::POPPERS[exten]
      popper.popup(reference_number)
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
      FSR::Log.info "Popping #{lead} for #{@extension}"
      send_data "(#{lead})"
    end
  end
end

dl_options = TinyDialer.options.direct_listener
td_options = TinyDialer.options.dialer

EM.epoll?
EventMachine::run do
  FSR::Log.info "Connecting DialEventListener to #{td_options.fs_server_ip}:#{td_options.fs_server_port}"
  EventMachine::connect td_options.fs_server_ip, td_options.fs_server_port, TinyDialer::DialEventListener, host: td_options.fs_server_ip, port: td_options.fs_server_port, auth: td_options.fs_auth, output_format: 'plain'

  FSR::Log.info "Start CUBS Popper Server on 0.0.0.0:9186"
  EventMachine::start_server "0.0.0.0", 9186, TinyDialer::CubsPopper

  FSR::Log.info "Start DirectListener Popper Server on #{dl_options.host}:#{dl_options.port}"
  EventMachine::start_server dl_options.host, dl_options.port, TinyDialer::DirectListener, host: dl_options.host, port: dl_options.port, queue_server: dl_options.tcc_server
end
