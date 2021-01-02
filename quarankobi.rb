require 'date'
require 'sinatra'
require 'time_difference'
require_relative './helpers/db'

DB = Db.new

class Base < Sinatra::Base
  configure :production, :development do
      enable :logging
      set    :public_folder, 'public'
      set    :views,         'views'
      set    :erb, escape_html: true,
                   layout_options: {views: 'views/layouts'}
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
    DB.set_name(request.ip, params['Name'])
    redirect '/'
  end

  get '/cheatering' do
    haml :cheatering
  end

  post '/cheatering' do
    day = params['day'].to_i;
    completed = params['completed'] == "true";
    DB.cheatering(request.ip, day, completed)
    redirect '/'
  end

  get '/' do
    day, reached, completed, name = DB.day(request.ip)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    if ENV['RACK_ENV'] == "development"
      difference = TimeDifference.between(now, reached).in_seconds
    else
      difference = TimeDifference.between(now, reached).in_hours
    end
    if difference > 16 && completed && day != 5
      DB.next_day(request.ip)
      redirect '/'
    end

    case day
    when 1
      DB.complete(request.ip, 1)
      haml :day_1, locals: {name: name}
    when 2
      day_2(name, "/", completed)
    when 3
      day_3(request.ip, name)
    when 4
      DB.complete(request.ip, 4)
      erb :day_4, locals: {name: name}
    when 5
      day_5(name, '/', completed)
    else
      day_5(name, '/', completed)
    end
  end

  get '/day_1' do
    day, reached, completed, name = DB.day(request.ip)

    haml :day_1, locals: {name: name}
  end

  get '/day_2' do
    day, reached, completed, name = DB.day(request.ip)
    redirect '/' if day < 2

    day_2(name, '/day_2', day > 2)
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

    day_5(name, '/day_5', completed)
  end

  def day_2(name, redirect_url, completed)
    score = params['score']
    if score
      score = params['score'].delete(",")
    end
    score = score.to_i || nil
    if score >= 15000
      DB.complete(request.ip, 2)
    end
    haml :day_2, locals: {score: score, name: name, redirect_url: redirect_url, completed: completed}
  end

  def day_3(ip, name)
    # increment the visit counter
    DB.visit(ip)
    # get total visits
    count = DB.visits(ip)
    # number of refreshes until message + message.length
    if count > 51
      DB.complete(ip, 3)
    end
    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    message.push("did you get all that?")
    haml :day_3, locals: {count: count, message: message, name: name}
  end

  def day_5(name, redirect_url, completed)
    kj = params['kj']
    if kj
      kj = params['kj'].delete(",")
    end
    kj = kj.to_i || nil
    if kj == 5710
      DB.complete(request.ip, 5)
    end
    erb :day_5, locals: {kj: kj, name: name, redirect_url: redirect_url, completed: completed}
  end

end
