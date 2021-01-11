class AdminController < BaseController
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
