require 'date'
require 'time_difference'
require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_10'
require_relative './helpers/day_11'

class QuaranKobiController < BaseController
  include Day2, Day3, Day5, Day6, Day7, Day10, Day11

  get '/' do
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    if ENV['RACK_ENV'] == "production"
      difference = TimeDifference.between(now, @user.reached).in_hours
    else
      difference = TimeDifference.between(now, @user.reached).in_seconds
    end

    if difference > 16 && @user.completed && @user.day != 13
      @user.next
      Peep.save(@user)
      redirect '/'
    end

    case @user.day
    when 1
      @user.complete
      Peep.save(@user)
      haml :day_1, locals: {name: @user.name}
    when 2
      day_2(@user)
    when 3
      day_3(@user)
    when 4
      if !@user.completed
        @user.complete
        Peep.save(@user)
      end
      erb :day_4, locals: {name: @user.name}
    when 5
      day_5(@user)
    when 6
      day_6(@user, '/', params)
    when 7
      day_7(@user, params['answer'])
    when 8
      code = params['code'] || ""
      if code.delete(" ").delete(",").delete("/").downcase == "ner" && !@user.completed
        @user.complete
        Peep.save(@user)
      end
      erb :day_8, locals: {name: @user.name, completed: @user.completed}
    when 9
      erb :day_9, locals: {name: @user.name, completed: @user.completed}
    when 10
      day_10(@user, params['code'])
    when 11
      day_11(@user, params['code'])
    when 12
      if params['code']
        code = params['code'].delete(" ").delete("/")
      end

      if code && (code == "-......" || code.downcase == "bs")
        @user.complete
        Peep.save(@user)
      end

      erb :day_12, locals: {completed: @user.completed, name: @user.name}
    when 13
      erb :day_13, locals: {name: @user.name}
    else
      "Something is bad."
    end
  end

end
