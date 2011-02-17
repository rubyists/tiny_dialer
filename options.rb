require 'innate'

module TinyDialer
  include Innate::Optioned

  options.dsl do |o|
    o.sub :direct_listener do
      o "Port", :port,
        ENV['TD_DIRECT_LISTENER_PORT'] || 8084
      o "Host", :host,
        ENV['TD_DIRECT_LISTENER_HOST'] || "127.0.0.1"
      o "Queue Server", :tcc_server,
        ENV['TD_DIRECT_LISTENER_QUEUE_SERVER'] || "127.0.0.1"
      o "Tiny Call Center Root", :tcc_root,
        ENV['TCC_ROOT'] || File.expand_path("../tiny_call_center")
    end

    o.sub :dialer do
      o "Proxy Server",
        :proxy_server, ENV['TD_Proxy_Server']
      o "Maximum amount of Dials at the same time",
        :max_dials, ENV['TD_Max_Dials'].to_i
    end
  end
end
