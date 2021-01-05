require 'date'
require 'time_difference'
require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_11'
require_relative './helpers/day_12'

class QuaranKobiController < Sinatra::Base
  include Day2, Day3, Day5, Day6, Day7, Day11, Day12

  get '/' do
    id = session['uuid']
    if id == nil
      puts "getting id"
      id = DB.id(request.ip)
      session['uuid'] = id
    end

    if DB.ip(id) != request.ip
      DB.update_ip(id, request.ip)
    end

    day, reached, completed, name = DB.day(id)
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    if ENV['RACK_ENV'] == "development"
      difference = TimeDifference.between(now, reached).in_seconds
    else
      difference = TimeDifference.between(now, reached).in_hours
    end
    if difference > 16 && completed && day != 9
      DB.next_day(id)
      redirect '/'
    end

    case day
    when 1
      if !completed
        DB.complete(id, 1)
      end
      haml :day_1, locals: {name: name}
    when 2
      day_2(name, completed)
    when 3
      day_3(id, name, completed)
    when 4
      if !completed
        DB.complete(id, 4)
      end
      erb :day_4, locals: {name: name}
    when 5
      day_5(name, completed)
    when 6
      day_6(id, name, params, '/', completed)
    when 7
      day_7(name, completed, params['answer'])
    when 8
      code = params['code'] || ""
      if code.delete(" ").delete(",").delete("/").downcase == "ner" && !completed
        DB.complete(id, 8)
        completed = true
      end

      erb :day_8, locals: {name: name, completed: completed}
    when 9
      erb :day_9, locals: {name: name, completed: completed}
    when 11
      day_11(name, completed, params['code'])
    when 12
      day_12(id, name, params['code'], completed)
    else
      "Something is bad."
    end
  end

  get '*' do
    erb :not_found
  end
end
