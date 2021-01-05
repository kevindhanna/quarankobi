require 'date'
require 'securerandom'
require_relative './db_connection'

class DB
  @connection = DbConnection.new

  def self.find(table, column, value)
    results = @connection.query("SELECT * FROM #{table} WHERE #{column} = #{value}")
    if results.count > 1
      results.to_a
    elsif results.count == 1
      results.to_a[0]
    else
      nil
    end
  end

  def self.update(table, key, values)
    # [ 'id', "'abcd-1234'" ]
    key, value = key
    fields = values.map do |k, v|
      "#{k} = #{v}"
    end
    fields = fields.join(", ")

    sql = "UPDATE #{table} SET #{fields} where #{key}=#{value}"
    @connection.query(sql)
  end

  def self.insert(table, props)
    keys = props.keys.join(", ")
    values = props.values.join(", ")
    sql = "INSERT INTO #{table} (#{keys}) VALUES (#{values})"
    @connection.query(sql)
  end

  # gross wrapper to stop throws for very quick refreshes on day 3

  def self.day_data
    results = @connection.query("SELECT * from peeps")
    results = results.map do |entry|
      {
        id: entry[:id],
        ip: entry[:ip],
        name: entry[:name],
        day: entry[:day],
        completed: (entry[:completed]),
        reached: entry[:reached].is_a?(String) ? DateTime.parse(entry[:reached]) : entry[:reached],
        day_3_count: entry[:day_3_count],
        day_9_twister: entry[:day_9_twister],
      }
    end
    results
  end

  def self.reset
    @connection.query("DELETE FROM visits")
    @connection.query("DELETE FROM peeps")
    @connection.query("DELETE FROM day_6_answers")
    @connection.query("DELETE FROM day_11_history")
    @connection.query("DELETE FROM day_9")
  end

  def self.cheatering(id, day, completed)
    @connection.query("UPDATE peeps SET day=#{day}, completed=#{completed}, reached='#{DateTime.now}' WHERE id='#{id}'")
    if day == 9
      set_day_9(id, 4)
    end
  end
end
