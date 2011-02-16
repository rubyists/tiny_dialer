module TinyDialer
  module TCC_Helper
    def self.ready_agents
      reg_servers = {}
      all_agents = agents

      all_agents.each { |n|
        n.ext = TinyCallCenter::Account.extension(n.name)
        n.reg_server = TinyCallCenter::Account.registration_server(n.ext)
        reg_servers[n.reg_server] ||= FSR::CommandSocket.new(:server => n.reg_server).channels.run
      }

      all_agents.select { |agent|
        agent.status =~ /Available/ &&
          !reg_servers[agent.reg_server].detect { |ch| 
            ch.dest == agent.ext || ch.name =~ /(?:^|\/)(?:sip:)?#{agent.ext}[@-]/
        }
      }
    end

    def self.agents
      require TinyDialer.options.direct_listener.tcc_root + "/model/init"
      all = FSR::CommandSocket.new(:server => TinyDialer.options.direct_listener.tcc_server)
      all.call_center(:agent).list.run
    end
  end
end

