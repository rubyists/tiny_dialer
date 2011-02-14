module TinyDialer
  include Ramaze::Optioned

  options.dsl do |o|
    o.sub :direct_listener do
      o "Port", :port,
        ENV['TD_DIRECT_LISTENER_PORT'] || 8084
      o "Host", :host,
        ENV['TD_DIRECT_LISTENER_HOST'] || "127.0.0.1"
      o "Queue Server", :queue_server,
        ENV['TD_DIRECT_LISTENER_QUEUE_SERVER'] || "127.0.0.1"
    end
  end
end
