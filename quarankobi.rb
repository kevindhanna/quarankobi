require 'mysql2'
require 'sinatra'

class Base < Sinatra::Base
  configure :production, :development do
      enable :logging
      set    :public_folder, 'public'
      set    :views,         'views'
      set    :erb, escape_html: true,
                   layout_options: {views: 'views/layouts'}
  end

  get '/day_1' do
    haml :day_1
  end

  get '/day_2' do
    score = params['score'].to_i || nil
    haml :day_2, locals: {score: score}
  end
end
