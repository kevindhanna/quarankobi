require 'date'
require 'time_difference'
require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_11'

class QuaranKobiController < Sinatra::Base
  include Day2, Day3, Day5, Day6, Day7, Day11

  get '/' do
    day, reached, completed, name = DB.day(request.ip)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    if ENV['RACK_ENV'] == "development"
      difference = TimeDifference.between(now, reached).in_seconds
    else
      difference = TimeDifference.between(now, reached).in_hours
    end
    if difference > 16 && completed && day != 7 && day != 11
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
    when 9
      erb :day_9, locals: {name: name, completed: completed}
    when 11
      day_11(name, completed, params['code'])
    else
      day_7(name, completed)
    end
  end

end
