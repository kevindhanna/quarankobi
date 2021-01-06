class Auth
  def initialize app
    @app = app
  end

  def call env
    session = env['rack.session']
    ip = env['REMOTE_ADDR']
    id = session['uuid']

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
    if !id && !user
      begin
        env[:user] = Peep.find_by_ip(ip)
      rescue PeepNotFound
        user = Peep.create(ip)
        Peep.save(user)
        env[:user] = user
      end
    end

    if user
      session['uuid'] = user.id
    end
    @app.call env
  end
end
