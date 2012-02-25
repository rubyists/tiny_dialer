require 'fsr'
require 'fsr/listener/outbound'
module TinyDialer
  class MenuListener < FSR::Listener::Outbound
    attr_reader :lead

    WELCOME_WAV = "/home/freeswitch/freeswitch/sounds/en/us/hello.wav"
    IF_YOU_ARE_WAV = "/home/freeswitch/freeswitch/sounds/en/us/if-you-are-that.wav"
    PRESS_ONE_WAV = "/home/freeswitch/freeswitch/sounds/en/us/press-one.wav"
    INVALID_WAV = "/home/freeswitch/freeswitch/sounds/en/us/please-try-again.wav"

    def session_initiated
      answer do
        id = session.headers[:variable_lead_id]
        @lead = Lead[:id => id]
        if lead
          play_message
        else
          Log.info "Did not find lead with #{id}"
          hangup
          close_connection
        end
      end
    end

    def play_message
      lead.update(:status => 'ANSWER', :timestamp => Time.now)
      @record = TinyDialer::Record.create(:timestamp => Time.now, :status => "CALLING", :reference_number => lead.reference_number.to_s, :first_name => lead.first_name.to_s, :last_name => lead.last_name.to_s, :phone => lead.phone.to_s, :zip => lead.zip.to_s)
      playback(WELCOME_WAV) do
        update_session do
          Log.info "#{Time.now} - #{session.headers[:variable_amd_status].to_s} answered (#{session.headers[:variable_amd_result]}) - #{lead.first_name} #{lead.last_name} #{lead.reference_number}"
          if session.headers[:variable_amd_status].to_s != "machine"
            @record.update(:status => "ANSWERED")
            Log.info "A person answered, playing initial first/last name question: #{lead.first_name} #{lead.last_name} #{lead.reference_number}"
            speak("#{lead.first_name.to_s} #{lead.last_name.to_s}", {:voice => 'diane', :engine => 'cepstral'}) do
              Log.info "getting input: #{lead.first_name} #{lead.last_name} #{lead.reference_number}"
              get_input
            end
          else
            @record.update(:status => "MACHINE_ANSWERED")
            set("first_name", "#{lead.first_name}") do
              set("last_name", "#{lead.last_name}") do
                set("reference_number", "#{lead.reference_number.to_s.split(%r{\s*}).join(' ')}") do
                  Log.info "#{Time.now} - Leaving a message for #{lead.first_name} #{lead.last_name} #{lead.reference_number}"
                  lead.update(:status => 'ANS_MACH_LMTC', :timestamp => Time.now)
                  @record.update(:status => 'ANS_MACH_LMTC')
                  lead.write_status
                  transfer("7000 XML default") { close_connection }
                end
              end
            end
          end
        end
      end
    end

    def get_input
      Log.info "#{Time.now} - Playing IF_YOU_ARE for #{lead.first_name.to_s} #{lead.last_name.to_s}"
      playback(IF_YOU_ARE_WAV) do
        speak("#{lead.first_name.to_s} #{lead.last_name.to_s}", {:voice => 'diane', :engine => 'cepstral'}) do
          play_and_get_digits(PRESS_ONE_WAV, INVALID_WAV, 1, 1, 5, 7000, ["#"], "debtor_input", "\\d") do |choice|
            Log.info "#{Time.now} - #{lead.first_name.to_s} #{lead.last_name.to_s} entered #{choice.to_s.strip}"
            if choice
              case_input(choice)
            else
              Log.info "#{Time.now} - #{lead.first_name} #{lead.last_name} hung up"
              timestamp = Time.now
              lead.update(:status => 'REMOTE_PARTY_HU', :timestamp => timestamp)
              @record.update(:status => 'REMOTE_PARTY_HU')
              lead.write_status
            end
          end
        end
      end
    end

    def unbind
      if lead.status == "ANSWER"
        timestamp = Time.now
        lead.update(:status => 'REMOTE_PARTY_HU', :timestamp => timestamp)
        @record.update(:status => 'REMOTE_PARTY_HU')
        #lead.add_record(TinyDialer::Record.new(:status => 'REMOTE_PARTY_HU', :timestamp => timestamp))
        lead.write_status
      end
    end

    private

    def case_input(input)
      return direct_xfer # Always transfer to an agent no matter what they pressed
      case input.to_i
      when 1 then direct_xfer
      when 2 then leave_msg
      else wrong_number
      end
    end

    def direct_xfer
      Log.info "#{Time.now} - ##{lead.reference_number} #{lead.first_name} #{lead.last_name} transfered to queue"
      timestamp = Time.now
      lead.update(:status => 'DIRECT_XFER', :timestamp => timestamp)
      @record.update(:status => 'DIRECT_XFER')
      lead.write_status
      set("effective_caller_id_number", "Acct#{lead.reference_number}") do
        set("effective_caller_id_name", "#{@lead.first_name} #{@lead.last_name}") do
          transfer("9999 XML default") { close_connection }
        end
      end
    end

    def leave_msg
      Log.info "#{Time.now} - #{lead.first_name} #{lead.last_name} listened to message"
      timestamp = Time.now
      lead.update(:status => 'LMTC', :timestamp => timestamp)
      @record.update(:status => 'LMTC')
      lead.write_status
      set("first_name", "#{lead.first_name}") do
        set("last_name", "#{lead.last_name}") do
          set("reference_number", "#{lead.reference_number.to_s.split(%r{\s*}).join(' ')}") do
            lead.write_status
            transfer("7001 XML default") { close_connection }
          end
        end
      end
    end

    def wrong_number
      Log.info "#{Time.now} - #{lead.first_name} #{lead.last_name} is wrong number"
      timestamp = Time.now
      lead.update(:status => 'WRONG_NUMBER', :timestamp => timestamp)
      @record.update(:status => 'WRONG_NUMBER')
      lead.write_status
      speak("Thank you, Goodbye.", {:voice => "diane", :engine => "cepstral"}) { hangup }
    end

  end
end
