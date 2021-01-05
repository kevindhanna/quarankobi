class Auth
  def initialize app
    @app = app
  end

  def call env
    session = env['rack.session']
    ip = env['REMOTE_ADDR']
    id = session['uuid']
    puts "ip is #{ip}"
    puts "id os #{id}"
    if id
      user = Peep.find_buy_id(id)
      if user.ip != ip
        user.ip = ip
        Peep.save(user)
      end
      env[:user] = user
    else
      begin
        env[:user] = Peep.find_by_ip(ip)
      rescue PeepNotFound
        user = Peep.create(ip)
        Peep.save(user)
        env[:user] = user
      end
    end

    @app.call env
  end
end
