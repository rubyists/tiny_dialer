module TinyDialer
  class DialerPool < Sequel::Model
    set_dataset :dialer_pool
    DEFAULTS = {dialer_max: 100,
                ratio: 1.0,
                timestamp: Time.now,
                name: 'default_settings'
                }
    def self.initialize(settings = nil)
      record = if settings 
                 DEFAULTS.merge settings
               else
                 DEFAULTS
               end
      create record
    end

  end
end
