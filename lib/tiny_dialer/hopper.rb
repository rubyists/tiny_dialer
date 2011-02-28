require_relative '../tiny_dialer'
require 'singleton'

module TinyDialer
  class Hopper
    include Singleton
    attr_accessor :hopper, :max_size

    def initialize(args = {})
      @hopper = []
      @loading = false
      @max_size = args[:max_size] || 100
      @interval = 5
      EM.add_timer(@interval, method(:load_hopper_tick))
    end

    def self.create(args = {})
      new(args)
    end

    # Return next lead
    def next
      TinyDialer::Log.debug "Giving next lead: #{hopper.first}"
      hopper.unshift.pop
    end

    def today_start
      # Time.parse(Time.now.strftime("%d/%m/%Y") + " 00:00")
      _, _, _, d, m, y, = Time.now.to_a
      Time.local(y, m, d, 0, 0)
    end

    def today_end
      # Time.parse(Time.now.strftime("%d/%m/%Y") + " 23:59")
      _, _, _, d, m, y, = Time.now.to_a
      Time.local(y, m, d, 23, 59)
    end

    private

    def load_hopper_tick
      EM.defer do
        begin
          load_hopper if hopper.empty?
        ensure
          if hopper.empty?
            @interval = [10, @interval * 1.2].min
          else
            @interval = [5, @interval * 0.5].max
          end

          EM.add_timer(@interval, method(:load_hopper_tick))
        end
      end
    end

    def load_hopper
      TinyDialer::Log.debug "Hopper empty, loading"
      TinyDialer.db.transaction do |db|
        hopper_leads = TinyDialer::Lead.filter(:status => 'HOPPER').all

        # separate leads into the ones we can call and the ones we can't
        callable_leads, ignored_leads = hopper_leads.partition(&:call?)
        TinyDialer::Log.debug ["Callable Leads:", callable_leads, "Ignored Leads:", ignored_leads]

        # Set all the rest of the leads marked HOPPER back to NEW
        ignored_leads.each{|lead| lead.update(:status => "NEW") }

        if callable_leads.size < max_size
          TinyDialer::Log.debug "No callable leads in hopper, loading #{max_size - callable_leads.size} leads"
          new_leads = TinyDialer::Lead.filter(:status => 'NEW').
            order(:random.sql_function).
            limit(max_size - callable_leads.size).all
          TinyDialer::Log.debug "Found #{new_leads.size} new leads"
          callable_leads += new_leads.select{|lead| lead.call? }
          TinyDialer::Log.debug "#{callable_leads.size} total callable leads"
        end

        begin
          callable_leads.map! do |lead|
            # update lead status to hopper so it's not pulled again
            lead.update(:status => 'HOPPER')

            Log.info "Putting (#{lead.reference_number} #{lead.first_name} #{lead.last_name}) into hopper."
            lead
          end

          hopper.concat(callable_leads)
        rescue => e
          Log.error "Wo, something wrong in hopper lead mapping"
          Log.error e
        end
      end
    end
  end
end
