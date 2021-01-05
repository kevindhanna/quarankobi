require "./controllers/helpers/auth"

class AdminController < Sinatra::Base
  enable :sessions
  use Auth

  before do
    @id, = request.env.values_at :user
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
    DB.set_name(session['uuid'], params['Name'])
    redirect '/'
  end

  get '/cheatering' do
    haml :cheatering
  end

  post '/cheatering' do
    day = params['day'].to_i;
    completed = params['completed'] == "true";
    DB.cheatering(@id, day, completed)
    redirect '/'
  end
end
