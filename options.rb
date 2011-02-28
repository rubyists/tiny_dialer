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
        ENV['TD_TCC_SERVER'] || "127.0.0.1"
      o "Tiny Call Center Root (You must set this for Predictive Dialing)", :tcc_root,
        ENV['TCC_ROOT']
    end

    o.sub :dialer do
      o "Dial Server.  This server will originate dials", :dial_server,
        ENV['TD_Dial_Server'] || "127.0.0.1"
      o "Proxy Server Format String (sofia/internal/%s@proxy.server, loopback/%s/default/XML, etc)",
        :proxy_server_fmt, ENV['TD_Proxy_Server_Format_String']
      o "Maximum amount of Dials at the same time, defaults to 10",
        :max_dials, ENV['TD_Max_Dials'].to_i || 10
      o "Predictive? (true or leave blank for non-predictive)", :predictive, ENV["TD_Predictive"] || false
      o "Freeswitch Server IP For Dialing",
        :fs_server_ip, ENV['TD_FS_SERVER_IP'] || '127.0.0.1'
      o "Freeswitch Server Port For Dialing",
        :fs_server_port, (ENV['TD_FS_SERVER_PORT'] || 8021).to_i
      o "Freeswitch Server Password",
        :fs_auth, ENV['TD_FS_SERVER_AUTH'] || 'ClueCon'
    end
  end
end
