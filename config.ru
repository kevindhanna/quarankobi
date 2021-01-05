require 'dotenv/load'
require 'sinatra'
require "./database/db"
require "./models/peep"
require "./controllers/admin_controller"
require "./controllers/day_controller"
require "./controllers/quarankobi_controller"

Dotenv.load
Sinatra::Base::configure :production, :development do
  enable :logging
  set :session_secret, ENV.fetch('SESSION_SECRET')
  set    :public_folder, 'public'
  set    :views,         'views'
  set    :erb, escape_html: true,
         layout_options: {views: 'views/layouts'}

end

use AdminController
use DayController
run QuaranKobiController
