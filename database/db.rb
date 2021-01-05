require 'date'
require 'securerandom'
require_relative './setup'

class Db
  include DBSetup
  def initialize
    @client = setup_db
  end

  # gross wrapper to stop throws for very quick refreshes on day 3
  def query(sql, sleep_count = 0)
    begin
      @client.query(sql)
    rescue Mysql2::Error => e
      # throw if we've been waiting for 2 seconds
      throw e if sleep_count > 48
      sleep(1.0/24.0)
      query(sql, sleep_count + 1)
    end
  end

  def day_data
    results = query("SELECT * from peeps")
    results = results.map do |entry|
      {
        id: entry['id'],
        ip: entry['ip'],
        name: entry['name'],
        day: entry['day'],
        completed: (entry['completed'] == 1),
        reached: entry['reached'].is_a?(String) ? DateTime.parse(entry['reached']) :entry['reached']
      }
    end
    results
  end

  def id(ip)
    results = query("SELECT id FROM peeps WHERE ip ='#{ip}'")
    results.each do |r|
      return r['id']
    end

    # if we didn't return above we have to create a new peep
    create(ip)
    id(ip)
  end

  def ip(id)
    results = query("SELECT ip FROM peeps WHERE id ='#{id}'")
    results.each do |r|
      return r['ip']
    end
  end

  def update_ip(id, ip)
    query("UPDATE peeps SET ip='#{ip}' WHERE id ='#{id}'")
  end

  def reset
    query("DELETE FROM visits")
    query("DELETE FROM peeps")
    query("DELETE FROM day_6_answers")
    query("DELETE FROM day_11_history")
    query("DELETE FROM day_9")
  end

  def cheatering(id, day, completed)
    query("UPDATE peeps SET day=#{day}, completed=#{completed}, reached='#{DateTime.now}' WHERE id='#{id}'")
  end

  def visits(id)
    results = query("SELECT count FROM visits WHERE id='#{id}'")
    results.each do |r|
      return r['count'].to_i
    end
  end

  def visit(id)
    if !visited?(id)
      query("INSERT INTO visits (id, count) VALUES ('#{id}', 0)")
    end
    query("UPDATE visits SET count=count+1 WHERE id='#{id}'")
  end

  def day(id)
    results = query("SELECT day, reached, completed, name FROM peeps WHERE id='#{id}'")
    results.each do |r|
      return [r['day'], r['reached'], (r['completed'] == 1), r['name']]
    end
  end

  def next_day(id)
    date = DateTime.now
    query("UPDATE peeps SET day=day+1, completed=false, reached='#{date}' WHERE id = '#{id}'")
  end

  def complete(id, day)
    puts "completeing #{day} for #{id}"
    query("UPDATE peeps SET completed=true WHERE id='#{id}' AND day=#{day}")
  end

  def set_name(id, name)
    query("UPDATE peeps SET name='#{name}' WHERE id='#{id}'")
  end

  def set_day_6_answers(id, answers)
    if !answered?(id)
      query("INSERT INTO day_6_answers (id, answers) VALUES ('#{id}', '#{answers}')")
    else
      query("UPDATE day_6_answers SET answers='#{answers}' where id='#{id}'")
    end
  end

  def day_6_answers(id)
    result = query("SELECT answers FROM day_6_answers WHERE id='#{id}'")
    result.each do |r|
      return r['answers']
    end
    ""
  end

  def set_day_11_history(id, history)
    if !has_history(id)
      query("INSERT INTO day_11_history (id, history) VALUES ('#{id}', '#{history}')")
    end
    query("UPDATE day_11_history SET history='#{history}' WHERE id='#{id}'")
  end

  def day_11_history(id)
    results =  query("SELECT history FROM day_11_history WHERE id='#{id}'")
    results.each do |r|
      return r['history']
    end
    "{\"history\": []}"
  end

  def name(id)
    result = query("SELECT name FROM peeps WHERE id='#{id}'")
    result.each do |r|
      return r['name']
    end
  end

  def set_day_9(id, twister)
      query("UPDATE day_9 SET twister=#{twister} where id='#{id}'")
  end

  def day_9(id)
    if !has_day_9?(id)
      query("INSERT INTO day_9 (id, twister) VALUES ('#{id}', 0)")
      return 1
    end

    result = query("SELECT twister FROM day_9 where id='#{id}'")
    result.each do |r|
      return r['twister']
    end
  end

  private

  def create(ip)
    date = DateTime.now
    query("INSERT INTO peeps (id, ip, day, completed, reached) VALUES ('#{SecureRandom.uuid}', '#{ip}', 1, false, '#{date}')")
  end

  def played?(id)
    result = query("SELECT id FROM peeps WHERE id = '#{id}'")
    result.each do |r|
      return true if r['id'] == id
    end

    false
  end

  def visited?(id)
    result = query("SELECT id FROM visits WHERE id = '#{id}'")
    result.each do |r|
      return true if r['id'] == id
    end

    false
  end

  def answered?(id)
    result = query("SELECT id FROM day_6_answers WHERE id = '#{id}'")
    result.each do |r|
      return true if r['id'] == id
    end

    false
  end

  def has_history(id)
    result = query("SELECT id FROM day_11_history WHERE id = '#{id}'")
    result.each do |r|
      return true if r['id'] == id
    end

    false
  end

  def has_day_9?(id)
    result = query("SELECT id FROM day_9 WHERE id = '#{id}'")
    result.each do |r|
      return true if r['id'] == id
    end

    false
  end
end
