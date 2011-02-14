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
      @hopper_loader = false
    end

    def self.create(args = {})
      new(args)
    end

    # Return next lead
    def next
      load_hopper_start unless @hopper_loader
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

    def load_hopper_start
      @interval = 5
      @hopper_loader = EM.add_periodic_timer(@interval, method(:load_hopper_tick))
    end

    def load_hopper_tick
      @hopper_loader.cancel

      EM.defer do
        begin
          load_hopper if hopper.empty?
        ensure
          if hopper.empty?
            @interval = [60, @interval * 1.5].min
          else
            @interval = [5, @interval * 0.5].max
          end

          @hopper_loader = EM.add_periodic_timer(@interval, method(:load_hopper_tick))
        end
      end
    end

    def load_hopper
      TinyDialer.db.transaction do |db|
        hopper_leads = TinyDialer::Lead.filter(:status => 'HOPPER').all

        # separate leads into the ones we can call and the ones we can't
        callable_leads, ignored_leads = hopper_leads.partition(&:call?)

        # Set all the rest of the leads marked HOPPER back to NEW
        ignored_leads.each{|lead| lead.update(:status => "NEW") }

        if callable_leads.size < max_size
          callable_leads +=  TinyDialer::Lead.filter(:status => 'NEW').
            order(:random.sql_function).
            limit(max_size - callable_leads.size).all
        end

        callable_leads.map! do |lead|
          # update lead status to hopper so it's not pulled again
          lead.update(:status => 'HOPPER')

          Log.info "Putting (#{lead.debtor_id} #{lead.first_name} #{lead.last_name}) into hopper."
          lead
        end

        hopper.concat(callable_leads)
      end
    end
  end
end
