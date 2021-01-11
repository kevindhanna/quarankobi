require 'dotenv/load'
require 'sinatra'
require "./database/db"
require "./models/peep"
require "./controllers/base_controller"
require "./controllers/admin_controller"
require "./controllers/day_controller"
require "./controllers/quarankobi_controller"

Dotenv.load

use AdminController
use DayController
run QuaranKobiController
