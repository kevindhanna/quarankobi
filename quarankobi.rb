require 'date'
require 'sinatra'
require 'time_difference'
require_relative './helpers/db'
require_relative './helpers/day_6'

DB = Db.new

class Base < Sinatra::Base
  configure :production, :development do
      enable :logging
      set    :public_folder, 'public'
      set    :views,         'views'
      set    :erb, escape_html: true,
                   layout_options: {views: 'views/layouts'}
  end

  include Day6

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
    if difference > 16 && completed && day != 7
      DB.next_day(request.ip)
      redirect '/'
    end

    case day
    when 1
      DB.complete(request.ip, 1)
      haml :day_1, locals: {name: name}
    when 2
      day_2(name, completed)
    when 3
      day_3(request.ip, name)
    when 4
      DB.complete(request.ip, 4)
      erb :day_4, locals: {name: name}
    when 5
      day_5(name, completed)
    when 6
      day_6(request.ip, name, params, '/')
    when 7
      day_7(name, completed, params['answer'])
    else
      day_7(name, completed)
    end
  end

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
    erb :day_11, locals: {name: "kevin"}
  end

  def day_2(name, completed)
    score = params['score']
    if score
      score = params['score'].delete(",")
    end
    score = score.to_i || nil
    if score >= 15000
      DB.complete(request.ip, 2)
      completed = true
    end
    haml :day_2, locals: {name: name, completed: completed, score: score}
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

  def day_5(name, completed)
    kj = params['kj']
    if kj
      kj = params['kj'].delete(",")
    end
    kj = kj.to_i || nilp
    if kj == 5710
      DB.complete(request.ip, 5)
      completed = true
    end
    erb :day_5, locals: {name: name, completed: completed, kj: kj}
  end

  def day_6(ip, name, params, redirect_url)
    answers = {}
    # see if they've visited before, if so populate answers for them
    # because I'm nice
    if params.length == 0
      params = DB.day_6_answers(request.ip)
      if params.length > 0
        redirect "#{redirect_url}?#{params}"
      end
    else
      DB.set_day_6_answers(ip, request.query_string)
      result, answers = validate_answers(params)
    end

    if result
      DB.complete(request.ip, 6)
    end

    erb :day_6, locals: {name: name, submitted: params.length > 0, result: result, answers: answers}
  end

  def day_7(name, completed, answer)
    if answer
      answer = answer.delete(" ").delete("/").delete(",").downcase
    end
    if answer == "lbh"
      DB.complete(request.ip, 7)
      completed = true
    end
    erb :day_7, locals: {name: name, completed: completed}
  end
end
