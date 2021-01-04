require 'mysql2'

module DBSetup
  def setup_db
    client = Mysql2::Client.new(:host => ENV['HOST'],
                             :username => ENV['USERNAME'],
                             :password => ENV["PASSWORD"],
                             :database => ENV['DATABASE'],
                             :reconnect => true)
    run_migrations(client)
    client
  end

  def run_migrations(client)
    migrations = Dir.glob("./database/migrations/*.rb")

    maybe_create_migrations(client)

    ran = client.query("SELECT name FROM migrations").map do |result|
      result['name']
    end;

    migrations.each_with_index do |m, i|
      if !ran.include?(m)
        load m
        run(client)
        client.query("INSERT INTO migrations (name) VALUES ('#{m}')")
      end
    end
  end

  def maybe_create_migrations(client)
    begin
      client.query("create table migrations (name varchar(100))")
    rescue
      # nothing to see here
    end
  end
end
