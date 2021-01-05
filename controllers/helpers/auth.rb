class Auth
  def initialize app
    @app = app
  end

  def call env
    session = env['rack.session']
    ip = env['REMOTE_ADDR']

    id = session['uuid']
    if id == nil
      id = DB.id(ip)
      session['uuid'] = id
    end

    if DB.ip(id) != ip
      DB.update_ip(id, ip   )
    end

    env[:user] = id
    @app.call env
  end
end
