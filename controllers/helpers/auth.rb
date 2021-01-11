class Auth
  WHITELIST = [
    "/js",
    "/img",
    "/css",
    "/icon",
    "/data",
    "/audio",
    "/fonts",
    "/effects"
  ]

  def initialize app
    @app = app
  end

  def call env
    if whitelisted?(env['REQUEST_URI'])
      return @app.call env
    end

    session = env['rack.session']
    ip = env['REMOTE_ADDR']
    id = session['uuid']
    user_agent = env['HTTP_USER_AGENT']

    if id
      begin
        user = Peep.find_by_id(id)
        if user.ip != ip
          user.ip = ip
          Peep.save(user)
        end
        env[:user] = user
      rescue PeepNotFound
        # do nothing
      end
    end

    if !env[:user]
      begin
        env[:user] = Peep.find_by_user_agent(user_agent)
      rescue PeepNotFound
        # do nothing
      end
    end

    if !env[:user]
      begin
        env[:user] = Peep.find_by_ip(ip)
      rescue PeepNotFound
        user = Peep.create(ip, user_agent)
        Peep.save(user)
        env[:user] = user
      end
    end

    if !env[:user]
      raise "No user"
    else
      user = env[:user]
      user.ip = ip
      user.user_agent = user_agent
      Peep.save(user)
      session['uuid'] = user.id
    end

    @app.call env
  end

  private

  def whitelisted?(uri)
    WHITELIST.each do |path|
      if uri.start_with? path
        return true
      end
    end
    false
  end
end
