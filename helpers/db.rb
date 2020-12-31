require 'mysql2'

class Db
  def initialize
    @client = Mysql2::Client.new(:host => ENV['HOST'],
                                 :username => ENV['USERNAME'],
                                 :password => ENV["PASSWORD"],
                                 :database => ENV['DATABASE'],
                                 :reconnect => true)
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
      add_ip(ip)
    end

    @client.query("UPDATE visits SET count=count+1 WHERE ip='#{ip}'")
  end

  def day(ip)
    if !has_day(ip)
      add_day(ip)
    end

    results = @client.query("SELECT day FROM days WHERE ip='#{ip}'")
    results.each do |r|
      return r['day'].to_i
    end
  end

  def next_day(ip)
    @client.query("UPDATE days SET day=day+1 WHERE ip = '#{ip}'")
  end

  private

  def add_ip(ip)
    @client.query("INSERT INTO visits (ip, count) VALUES ('#{ip}', 0)")
  end

  def add_day(ip)
    @client.query("INSERT INTO days (ip, day) VALUES ('#{ip}', 1)")
  end

  def has_visited(ip)
    result = @client.query("SELECT ip FROM visits WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def has_day(ip)
    result = @client.query("SELECT ip FROM days WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end
end
