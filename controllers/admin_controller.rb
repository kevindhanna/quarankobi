require "./controllers/helpers/auth"

class AdminController < Sinatra::Base
  # enable :sessions
  use Rack::Session::Cookie, :key => 'rack.session',
                            :domain => ENV['COOKIE_DOMAIN'],
                            :expire_after => 2592000, # In seconds
                            :secret => ENV['SESSION_SECRET']
  use Auth

  before do
    @user, = request.env.values_at :user
    session['uuid'] = @user.id
  end

  get '/reset' do
    DB.reset
    "DONE"
  end

  get '/sneaky' do
    days = DB.day_data

    haml :sneaky, locals: {days: days}
  end

  post '/set_name' do
    @user.name = params['Name']
    Peep.save(@user)
    redirect '/'
  end

  get '/cheatering' do
    haml :cheatering
  end

  post '/cheatering' do
    day = params['day'].to_i;
    completed = params['completed'] == "true";
    DB.cheatering(@user.id, day, completed)
    redirect '/'
  end

  get '/ip' do
    {ip: @id}.to_json
  end

  get '/name' do
    {name: @user.name}.to_json
  end
end
