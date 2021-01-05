require_relative './helpers/auth'
require_relative './helpers/day_2'
require_relative './helpers/day_3'
require_relative './helpers/day_5'
require_relative './helpers/day_6'
require_relative './helpers/day_7'
require_relative './helpers/day_11'
require_relative './helpers/day_12'

class DayController < Sinatra::Base
  include Day2, Day3, Day5, Day6, Day7, Day11, Day12
  enable :sessions
  use Auth

  before do
    @user, = request.env.values_at :user
  end

  get '/day_1' do
    haml :day_1, locals: {name: @user.name}
  end

  get '/day_2' do
    redirect '/' if @user.day <= 2

    day_2(@user)
  end

  get '/day_3' do
    redirect '/' if @user.day <= 3

    day_3(@user)
  end

  get '/day_4' do
    redirect '/' if @user.day <= 4

    erb :day_4, locals: {name: @user.name}
  end

  get '/day_5' do
    redirect '/' if @user.day <= 5

    day_5(@user)
  end

  get '/day_6' do
    redirect '/' if @user.day <= 6

    day_6(@user, '/day_6', params)
  end

  get '/day_7' do
    redirect '/' if @user.day <= 7

    day_7(@user, params['answer'])
  end

  get '/day_8' do
    redirect '/' if @user.day <= 8

    erb :day_8, locals: {name: @user.name, completed: @user.completed || @user.day > 8}
  end

  get '/day_9' do
    redirect '/' if @user.day <= 9

    erb :day_9, locals: {name: @user.name, completed: @user.day_9_twister < 4}
  end

  get '/day_9_twister' do
    puts @user.day_9_twister
    {twister: @user.day_9_twister}.to_json
  end

  put '/day_9' do
    current = @user.day_9_twister
    # there are 3 tongue twisters in an array
    if current < 4
      @user.day_9_twister += 1
    else
      @user.complete
    end
    Peep.save(@user)
  end

  get '/day_11' do
    redirect '/' if @user.day <= 11

    day_11(@user, params['code'])
  end

  get '/day_11_history' do
    @user.day_11_history
  end

  put '/day_11_history' do
    request.body.rewind
    history = request.body.read
    @user.day_11_history = history
    Peep.save(@user)
  end

  get '/day_12' do
    redirect '/' if @user.day <= 11

    day_12(@user, params['code'])
  end

end
