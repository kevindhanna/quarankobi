require "./controllers/helpers/auth"

class BaseController < Sinatra::Base
    # if ENV['RACK_ENV'] == "production"
        set :environment, :production
    # else
        # set :environment, :development
    # end
    configure :production, :development do
        puts File.dirname(__FILE__)
        enable  :logging
        set     :session_secret,  ENV.fetch('SESSION_SECRET')
        set     :static,          true
        set     :root,            File.dirname(__FILE__)
        set     :public_folder,   Proc.new { File.join(root, "../public") }
        set     :views,           Proc.new { File.join(root, "../views") }
        set     :erb, escape_html: true
    end

    use Rack::Session::Cookie, :key => 'rack.session',
        :domain => ENV['COOKIE_DOMAIN'],
        :expire_after => 2592000, # In seconds
        :secret => ENV['SESSION_SECRET']

    use Auth

    before do
        @user, = request.env.values_at :user
        session['uuid'] = @user.id
    end

    error 404 do
        puts "NOT HERE"
        erb :not_found
    end

    error 500 do
        puts "ERROR"
        puts env['sinatra.error']
        env['rack.errors'].class
    end
end
