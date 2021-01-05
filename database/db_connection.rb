require 'mysql2'

class DbConnection
  def initialize
    @client = Mysql2::Client.new(:host => ENV['HOST'],
                             :username => ENV['USERNAME'],
                             :password => ENV["PASSWORD"],
                             :database => ENV['DATABASE'],
                             :reconnect => true)
    run_migrations
  end

  def query(sql, sleep_count = 0)
    @client.query(sql, {
        symbolize_keys: true,
        cast_booleans: true
      })
  end

  private

  def run_migrations
    migrations = Dir.glob("./database/migrations/*.rb").sort
    puts migrations

    begin
      @client.query("create table migrations (name varchar(100))")
    rescue
      # nothing to see here
    end

    ran = @client.query("SELECT name FROM migrations").map do |result|
      result['name']
    end;

    migrations.each_with_index do |m, i|
      if !ran.include?(m)
        load m
        run(@client)
        @client.query("INSERT INTO migrations (name) VALUES ('#{m}')")
      end
    end
  end
end
