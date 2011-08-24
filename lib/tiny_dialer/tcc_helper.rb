module TinyDialer
  module TCC_Helper
    def self.ready_agents(queue = nil)
      reg_servers = {}
      all_agents = agents
      if queue
        members = Hash[tier_members(queue).map { |t| [t.agent, t.state] }]
        our_agents = all_agents.select { |a| members.key?(a.name) }
      else
        our_agents = all_agents
      end

      our_agents.each { |n|
        n.ext = TinyCallCenter::Account.extension(n.name)
        n.reg_server = TinyCallCenter::Account.registration_server(n.ext)
        reg_servers[n.reg_server] ||= FSR::CommandSocket.new(:server => n.reg_server).channels.run
      }

      our_agents.select { |agent|
        next unless agent.status =~ /Available/ # only select Available
        next unless members[agent.name] =~ /Ready/
        channels = reg_servers[agent.reg_server]
        channels.select{|channel|
          next if channel.dest == '19999' # ignore calls with dest
          channel.dest == agent.ext || channel.name =~ /(?:^|\/)(?:sip:)?#{agent.ext}[@-]/
        }.empty?
      }
    end

    def self.agents
      require TinyDialer.options.direct_listener.tcc_root + "/model/init"
      p(server_ip = TinyDialer.options.direct_listener.tcc_server)
      tcc_sock = FSR::CommandSocket.new(:server => server_ip)
      tcc_sock.call_center(:agent).list.run
    end

    def self.tier_members(queue = nil)
      require TinyDialer.options.direct_listener.tcc_root + "/model/init"
      tcc_sock = FSR::CommandSocket.new(:server => TinyDialer.options.direct_listener.tcc_server)
      all = tcc_sock.call_center(:tier).list.run
      return all unless queue
      all.select { |q| q.queue == queue }
    end
  end
end
