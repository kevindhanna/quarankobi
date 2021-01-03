require 'dotenv/load'
require 'sinatra'
require "./database/db"
require "./controllers/admin_controller"
require "./controllers/day_controller"
require "./controllers/quarankobi_controller"

Dotenv.load
DB = Db.new
Sinatra::Base::configure :production, :development do
  enable :logging
  set    :public_folder, 'public'
  set    :views,         'views'
  set    :erb, escape_html: true,
         layout_options: {views: 'views/layouts'}
end

use AdminController
use DayController
run QuaranKobiController
