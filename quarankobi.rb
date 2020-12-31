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

  get '/' do
    day, reached, completed = DB.day(request.ip)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    difference = TimeDifference.between(now, reached).in_seconds
    if difference > 16 && completed && day != 3
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
    else
      day_3(request.ip)
    end
  end

  get '/day_1' do
    haml :day_1
  end

  get '/day_2' do
    score = params['score'].to_i || nil
    day_2(score)
  end

  get '/day_3' do
    day_3(request.ip)
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
