require 'date'
require 'mysql2'

class Db
  def initialize
    @client = Mysql2::Client.new(:host => ENV['HOST'],
                                 :username => ENV['USERNAME'],
                                 :password => ENV["PASSWORD"],
                                 :database => ENV['DATABASE'],
                                 :reconnect => true)
  end

  def day_data
    results = @client.query("SELECT * from days")
    results = results.map do |entry|
      {
        ip: entry['ip'],
        day: entry['day'],
        completed: (entry['completed'] == 1),
        reached: entry['reached']
      }
    end
    results
  end

  def reset
    @client.query("DELETE FROM visits")
    @client.query("DELETE FROM days")
  end

  def visits(ip)
    results = @client.query("SELECT count FROM visits WHERE ip='#{ip}'")
    results.each do |r|
      return r['count'].to_i
    end
  end

  def visit(ip)
    if !has_visited(ip)
      @client.query("INSERT INTO visits (ip, count) VALUES ('#{ip}', 0)")
    end
    @client.query("UPDATE visits SET count=count+1 WHERE ip='#{ip}'")
  end

  def day(ip)
    if !has_day(ip)
      add_ip(ip)
    end

    results = @client.query("SELECT day, reached, completed FROM days WHERE ip='#{ip}'")
    results.each do |r|
      return [r['day'], r['reached'], (r['completed'] == 1)]
    end
  end

  def next_day(ip)
    date = DateTime.now
    @client.query("UPDATE days SET day=day+1, completed=false, reached='#{date}' WHERE ip = '#{ip}'")
  end

  def complete(ip, day)
    @client.query("UPDATE days SET completed=true WHERE ip='#{ip}' AND day=#{day}")
  end

  private

  def add_ip(ip)
    date = DateTime.now
    @client.query("INSERT INTO days (ip, day, completed, reached) VALUES ('#{ip}', 1, false, '#{date}')")
  end

  def has_day(ip)
    result = @client.query("SELECT ip FROM days WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def has_visited(ip)
    result = @client.query("SELECT ip FROM visits WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end
end
