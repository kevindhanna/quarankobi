class Auth
  def initialize app
    @app = app
  end

  def call env
    session = env['rack.session']
    ip = env['REMOTE_ADDR']
    id = session['uuid']
    user_agent = env['HTTP_USER_AGENT']
    puts "id is #{id}"
    puts "ip is #{ip}"

    if id
      begin
        user = Peep.find_by_id(id)
        puts "Got a user by ID"
        if user.ip != ip
          user.ip = ip
          Peep.save(user)
          puts "updated IP"
        end
        env[:user] = user
      rescue PeepNotFound
        puts "couldn't find by id"
        # do nothing
      end
    end

    if !env[:user]
      begin
        env[:user] = Peep.find_by_user_agent(user_agent)
        puts "found by agent"
      rescue PeepNotFound
        puts "couldn't find by ua"
        # do nothing
      end
    end

    if !env[:user]
      begin
        env[:user] = Peep.find_by_ip(ip)
        puts "found by ip"
      rescue PeepNotFound
        user = Peep.create(ip, user_agent)
        Peep.save(user)
        env[:user] = user
        puts "created a new one"
      end
    end

    if !env[:user]
      raise "No user"
    else
      user = env[:user]
      user.ip = ip
      user.user_agent = user_agent
      Peep.save(user)
      session['uuid'] = env[:user].id
    end

    @app.call env
  end
end
