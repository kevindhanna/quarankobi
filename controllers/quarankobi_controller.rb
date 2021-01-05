require 'date'
require 'time_difference'
require "./controllers/helpers/auth"
require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_11'
require_relative './helpers/day_12'

class QuaranKobiController < Sinatra::Base
  include Day2, Day3, Day5, Day6, Day7, Day11, Day12
  # enable :sessions
  use Rack::Session::Cookie, :key => 'rack.session',
                            :domain => ENV['COOKIE_DOMAIN'],
                            :expire_after => 2592000, # In seconds
                            :secret => ENV['SESSION_SECRET']
  use Auth

  before do
    @user, = request.env.values_at :user
  end

  get '/' do
    now = DateTime.now

    # if we've been on the current day for most of a day, we go up a day
    if ENV['RACK_ENV'] == "production"
      difference = TimeDifference.between(now, @user.reached).in_hours
    else
      difference = TimeDifference.between(now, @user.reached).in_seconds
    end

    if difference > 16 && @user.completed && @user.day != 9
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
    when 11
      day_11(@user, params['code'])
    when 12
      day_12(@user, params['code'])
    else
      "Something is bad."
    end
  end

  get '/*' do
    erb :not_found
  end
end
