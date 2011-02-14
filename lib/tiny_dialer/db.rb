begin
  require "sequel"
rescue LoadError
  require "rubygems"
  require "sequel"
end
require "logger"

module TinyDialer
  unless defined?(@@db)
    @@db = nil
  end

  def self.db
    setup_db
  end

  def self.db=(other)
    @@db = other
  end

  private

  def self.parse_pgpass(file, database)
    dbs = {}

    defaults = {
      host: "localhost", port: 5432, db: database,
      user: ENV["USER"], password: nil
    }

    file.readlines.each do |line|
      chunks = line.strip.split(/:/)
      dbs[chunks[2]] = Hash[defaults.keys.zip(chunks)]
    end

    chosen = (dbs[database] || dbs['*']).reject{|k,v| !v || v == '*' }
    defaults.merge(chosen)
  end

  def self.setup_db(root = TinyDialer::ROOT, default_app = 'tiny_dialer')
    return @@db if @@db

    app_db  = ENV["APP_DB"]  || default_app
    app_env = ENV["APP_ENV"] || "development"
    root_pgpass = root/".pgpass"
    home_pgpass = Pathname('~/.pgpass').expand_path

    if root_pgpass.file?
      conn = parse_pgpass(root_pgpass, app_db)
    elsif home_pgpass.file?
      conn = parse_pgpass(home_pgpass, app_db)
    else
      msg = "You have no %p or %p, can't determine connection"
      fail(msg % [root_pgpass.to_s, home_pgpass.to_s])
    end

    logfile = root/:log/"#{app_env}.log"
    logfile.parent.mkpath
    logger = ::Logger.new(logfile)

    if app_db.nil?
      logger.debug("setup_db called but no database defined")
      @@db = nil
    else
      logger.info("Connecting to #{app_db}")
      conn[:logger] = logger
      @@db = ::Sequel.postgres(app_db, conn)
    end
  end
end
