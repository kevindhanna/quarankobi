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
    day, completed = DB.day(request.ip)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    difference = TimeDifference.between(now, completed).in_seconds
    if difference > 16 && day != 3
      DB.next_day(request.ip)
      redirect '/'
    end

    redirect "day_#{day}"
  end

  get '/day_1' do
    haml :day_1
  end

  get '/day_2' do
    day, completed = DB.day(request.ip)

    if day < 2
      redirect '/'
    end

    score = params['score'].to_i || nil
    haml :day_2, locals: {score: score}
  end

  get '/day_3' do
    day, completed = DB.day(request.ip)

    if day < 3
      redirect '/'
    end

    # increment the visit counter
    DB.visit(request.ip)
    # get total visits
    count = DB.visits(request.ip)
    puts count
    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    haml :day_3, locals: {count: count, message: message}
  end

  get '/next_day' do
    DB.next_day(request.ip)
    redirect '/'
  end
end
