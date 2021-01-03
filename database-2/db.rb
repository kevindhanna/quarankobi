require 'date'
require_relative './setup'

class Db
  include DBSetup
  def initialize
    # @client = Mysql2::Client.new(:host => ENV['HOST'],
    #                              :username => ENV['USERNAME'],
    #                              :password => ENV["PASSWORD"],
    #                              :database => ENV['DATABASE'],
    #                              :reconnect => true)
    @client = setup_db
  end

  def day_data
    results = @client.execute("SELECT * from peeps")
    results = results.map do |entry|
      {
        ip: entry['ip'],
        name: entry['name'],
        day: entry['day'],
        completed: (entry['completed'] == 1),
        reached: entry['reached'].is_a?(String) ? DateTime.parse(entry['reached']) :entry['reached']
      }
    end
    results
  end

  def reset
    @client.execute("DELETE FROM visits")
    @client.execute("DELETE FROM peeps")
    @client.execute("DELETE FROM day_6_answers")
    @client.execute("DELETE FROM day_11_history")
  end

  def cheatering(ip, day, completed)
    @client.execute("UPDATE peeps SET day=#{day}, completed=#{completed}, reached='#{DateTime.now}' WHERE ip='#{ip}'")
  end

  def visits(ip)
    results = @client.execute("SELECT count FROM visits WHERE ip='#{ip}'")
    results.each do |r|
      return r[0]
    end
  end

  def visit(ip)
    if !has_visited(ip)
      @client.execute("INSERT INTO visits (ip, count) VALUES ('#{ip}', 0)")
    end
    @client.execute("UPDATE visits SET count=count+1 WHERE ip='#{ip}'")
  end

  def day(ip)
    if !has_day(ip)
      add_ip(ip)
    end

    results = @client.execute("SELECT day, reached, completed, name FROM peeps WHERE ip='#{ip}'")
    results.each do |r|
      return [r[0], DateTime.parse(r[1]), (r[2] == 1), r[3]]
    end
  end

  def next_day(ip)
    date = DateTime.now
    @client.execute("UPDATE peeps SET day=day+1, completed=false, reached='#{date}' WHERE ip = '#{ip}'")
  end

  def complete(ip, day)
    @client.execute("UPDATE peeps SET completed=true WHERE ip='#{ip}' AND day=#{day}")
  end

  def set_name(ip, name)
    @client.execute("UPDATE peeps SET name='#{name}' WHERE ip='#{ip}'")
  end

  def set_day_6_answers(ip, answers)
    p @client.execute("select sql from sqlite_master where name = 'day_6_answers'")
    if !has_answers(ip)
      @client.execute("INSERT INTO day_6_answers (ip, answers) VALUES ('#{ip}', '#{answers}')")
    else
      @client.execute("UPDATE day_6_answers SET answers='#{answers}' where ip='#{ip}'")
    end
  end

  def day_6_answers(ip)
    result = @client.execute("SELECT answers FROM day_6_answers WHERE ip='#{ip}'")
    result.each do |r|
      return r[0]
    end
    ""
  end

  def set_day_11_history(ip, history)
    if !has_history(ip)
      @client.execute("INSERT INTO day_11_history (ip, history) VALUES ('#{ip}', '#{history}')")
    end
    @client.execute("UPDATE day_11_history SET history='#{history}' WHERE ip='#{ip}'")
  end

  def day_11_history(ip)
    results =  @client.execute("SELECT history FROM day_11_history WHERE ip='#{ip}'")
    results.each do |r|
      return r
    end
    "{\"history\": []}"
  end

  private

  def add_ip(ip)
    date = DateTime.now
    @client.execute("INSERT INTO peeps (ip, day, completed, reached) VALUES ('#{ip}', 1, false, '#{date}')")
  end

  def has_day(ip)
    result = @client.execute("SELECT ip FROM peeps WHERE ip = '#{ip}'")
    result.each do |r|
      return r[0] == ip
    end

    false
  end

  def has_visited(ip)
    result = @client.execute("SELECT ip FROM visits WHERE ip = '#{ip}'")
    result.each do |r|
      return r[0] == ip
    end

    false
  end

  def has_answers(ip)
    result = @client.execute("SELECT ip FROM day_6_answers WHERE ip = '#{ip}'")
    result.each do |r|
      return r[0] == ip
    end

    false
  end

  def has_history(ip)
    result = @client.execute("SELECT ip FROM day_11_history WHERE ip = '#{ip}'")
    result.each do |r|
      return r[0] == ip
    end

    false
  end
end
