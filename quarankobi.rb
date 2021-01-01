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

  get '/' do
    day, reached, completed = DB.day(request.ip)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    difference = TimeDifference.between(now, reached).in_seconds
    if difference > 16 && completed && day != 4
      DB.next_day(request.ip)
      redirect '/'
    end

    case day
    when 1
      DB.complete(request.ip, 1)
      haml :day_1
    when 2
      score = params['score'].to_i || nil
      day_2(score)
    when 3
      day_3(request.ip)
    when 4
      DB.complete(request.ip, 4)
      erb :day_4
    else
      erb :day_4
    end
  end

  get '/day_1' do
    haml :day_1
  end

  get '/day_2' do
    day, reached, completed = DB.day(request.ip)
    redirect '/' if day < 2

    score = params['score'].to_i || nil
    day_2(score)
  end

  get '/day_3' do
    day, reached, completed = DB.day(request.ip)
    redirect '/' if day < 3

    day_3(request.ip)
  end

  get '/day_4' do
    day, reached, completed = DB.day(request.ip)
    redirect '/' if day < 4

    erb :day_4
  end

  def day_2(score)
    if score >= 15000
      DB.complete(request.ip, 2)
    end
    score = params['score'].to_i || nil
    haml :day_2, locals: {score: score}
  end

  def day_3(ip)
    # increment the visit counter
    DB.visit(ip)
    # get total visits
    count = DB.visits(ip)
    # number of refreshes until message + message.length
    if count > 51
      DB.complete(ip, 3)
    end
    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    haml :day_3, locals: {count: count, message: message}
  end
end
