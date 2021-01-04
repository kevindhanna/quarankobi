require 'date'
require_relative './setup'

class Db
  include DBSetup
  def initialize
    @client = setup_db
  end

  def day_data
    results = @client.query("SELECT * from peeps")
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
    @client.query("DELETE FROM visits")
    @client.query("DELETE FROM peeps")
    @client.query("DELETE FROM day_6_answers")
    @client.query("DELETE FROM day_11_history")
    @client.query("DELETE FROM day_9")
  end

  def cheatering(ip, day, completed)
    @client.query("UPDATE peeps SET day=#{day}, completed=#{completed}, reached='#{DateTime.now}' WHERE ip='#{ip}'")
  end

  def visits(ip)
    results = @client.query("SELECT count FROM visits WHERE ip='#{ip}'")
    results.each do |r|
      return r['count'].to_i
    end
  end

  def visit(ip)
    if !visited?(ip)
      @client.query("INSERT INTO visits (ip, count) VALUES ('#{ip}', 0)")
    end
    @client.query("UPDATE visits SET count=count+1 WHERE ip='#{ip}'")
  end

  def day(ip)
    if !played?(ip)
      add_ip(ip)
    end

    results = @client.query("SELECT day, reached, completed, name FROM peeps WHERE ip='#{ip}'")
    results.each do |r|
      return [r['day'], r['reached'], (r['completed'] == 1), r['name']]
    end
  end

  def next_day(ip)
    date = DateTime.now
    @client.query("UPDATE peeps SET day=day+1, completed=false, reached='#{date}' WHERE ip = '#{ip}'")
  end

  def complete(ip, day)
    @client.query("UPDATE peeps SET completed=true WHERE ip='#{ip}' AND day=#{day}")
  end

  def set_name(ip, name)
    @client.query("UPDATE peeps SET name='#{name}' WHERE ip='#{ip}'")
  end

  def set_day_6_answers(ip, answers)
    if !answered?(ip)
      @client.query("INSERT INTO day_6_answers (ip, answers) VALUES ('#{ip}', '#{answers}')")
    else
      @client.query("UPDATE day_6_answers SET answers='#{answers}' where ip='#{ip}'")
    end
  end

  def day_6_answers(ip)
    result = @client.query("SELECT answers FROM day_6_answers WHERE ip='#{ip}'")
    result.each do |r|
      return r['answers']
    end
    ""
  end

  def set_day_11_history(ip, history)
    if !has_history(ip)
      @client.query("INSERT INTO day_11_history (ip, history) VALUES ('#{ip}', '#{history}')")
    end
    @client.query("UPDATE day_11_history SET history='#{history}' WHERE ip='#{ip}'")
  end

  def day_11_history(ip)
    results =  @client.query("SELECT history FROM day_11_history WHERE ip='#{ip}'")
    results.each do |r|
      return r['history']
    end
    "{\"history\": []}"
  end

  def name(ip)
    result = @client.query("SELECT name FROM peeps WHERE ip='#{ip}'")
    result.each do |r|
      return r['name']
    end
  end

  def set_day_9(ip, twister)
      @client.query("UPDATE day_9 SET twister=#{twister} where ip='#{ip}'")
  end

  def day_9(ip)
    if !has_day_9?(ip)
      @client.query("INSERT INTO day_9 (ip, twister) VALUES ('#{ip}', 0)")
      return 1
    end

    result = @client.query("SELECT twister FROM day_9 where ip='#{ip}'")
    result.each do |r|
      return r['twister']
    end
  end

  private

  def add_ip(ip)
    date = DateTime.now
    @client.query("INSERT INTO peeps (ip, day, completed, reached) VALUES ('#{ip}', 1, false, '#{date}')")
  end

  def played?(ip)
    result = @client.query("SELECT ip FROM peeps WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def visited?(ip)
    result = @client.query("SELECT ip FROM visits WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def answered?(ip)
    result = @client.query("SELECT ip FROM day_6_answers WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def has_history(ip)
    result = @client.query("SELECT ip FROM day_11_history WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end

  def has_day_9?(ip)
    result = @client.query("SELECT ip FROM day_9 WHERE ip = '#{ip}'")
    result.each do |r|
      return true if r['ip'] == ip
    end

    false
  end
end
