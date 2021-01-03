require 'sqlite3'

module DBSetup
  def setup_db
    client = SQLite3::Database.new "./database/quarankobi.db"
    run_migrations(client)
    client
  end

  def run_migrations(client)
    migrations = Dir.glob("./database/migrations/*.rb")

    maybe_create_migrations(client)

    ran = client.execute("SELECT name FROM migrations").map do |result|
      result[0]
    end;
    migrations.each_with_index do |m, i|
      if !ran.include?(m)
        load m
        run(client)
        client.execute("INSERT INTO migrations (name) VALUES ('#{m}')")
      end
    end
  end

  def maybe_create_migrations(client)
    begin
      client.execute("create table migrations (name varchar(100))")
    rescue
      # nothing to see here
    end
  end
end
