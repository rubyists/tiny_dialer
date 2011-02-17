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
        next unless agent.status =~ /Available/ # only select Available
        channels = reg_servers[agent.reg_server]
        channels.select{|channel|
          next if channel.dest == '19999' # ignore calls with dest
          channel.dest == agent.ext || channel.name =~ /(?:^|\/)(?:sip:)?#{agent.ext}[@-]/
        }.empty?
      }
    end

    def self.agents
      require TinyDialer.options.direct_listener.tcc_root + "/model/init"
      all = FSR::CommandSocket.new(:server => TinyDialer.options.direct_listener.tcc_server)
      all.call_center(:agent).list.run
    end
  end
end
