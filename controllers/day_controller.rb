require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_11'

class DayController < Sinatra::Base
  include Day2, Day3, Day5, Day6, Day7, Day11


  get '/day_1' do
    day, reached, completed, name = DB.day(request.ip)

    haml :day_1, locals: {name: name}
  end

  get '/day_2' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 2

    day_2(name, day > 2)
  end

  get '/day_3' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 3

    day_3(request.ip, name)
  end

  get '/day_4' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 4

    erb :day_4, locals: {name: name}
  end

  get '/day_5' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 5

    day_5(name, day > 5)
  end

  get '/day_6' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 6

    day_6(request.ip, name, params, '/day_6')
  end

  get '/day_7' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 7

    day_7(name, day > 7, params['answer'])
  end

  get '/day_11' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 11

    day_11(name, completed, params['code'])
  end

  get '/day_11_history' do
    DB.day_11_history(request.ip)
  end

  post '/day_11_history' do
    request.body.rewind
    history = request.body.read
    DB.set_day_11_history(request.ip, history)
  end

  get '/ip' do
    {ip: request.ip}.to_json
  end

  get '/name' do
    name = DB.name(request.ip)
    {name: name}.to_json
  end
end
