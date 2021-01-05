require 'securerandom'

class Peep
  TABLE = "peeps"
  DEFAULT_DAY_11_HISTORY = "{\"history\": []}"
  @@repository = DB

  def self.find_by_id(id)
    params = @@repository.find(TABLE, "id", self.stringify(id))
    if params == nil
      raise PeepNotFound.new
    end
    Peep.new(**params)
  end

  def self.find_by_ip(ip)
    params = @@repository.find(TABLE, "ip", self.stringify(ip))
    if params == nil
      raise PeepNotFound.new
    end
    Peep.new(**params)
  end

  def self.create(ip)
    Peep.new(id: SecureRandom.uuid,
             ip: ip,
             name: nil,
             day: 1,
             completed: false,
             reached: DateTime.now,
             day_3_count: 0,
             day_6_answers: nil,
             day_9_twister: 0,
             day_11_history: DEFAULT_DAY_11_HISTORY)
  end

  def self.save(peep)
    props = self.serialize(peep)
    begin
      find_by_id(peep.id)
      @@repository.update(TABLE, ["id", self.stringify(peep.id)], props)
    rescue PeepNotFound
      @@repository.insert(TABLE, props)
    end
  end

  attr_reader :id, :ip, :day, :completed, :reached
  attr_accessor :name, :day_3_count, :day_6_answers, :day_9_twister, :day_11_history

  def initialize(id:,
                 ip:,
                 name:,
                 day:,
                 completed:,
                 reached:,
                 day_3_count:,
                 day_6_answers:,
                 day_9_twister:,
                 day_11_history:)
    @id = id
    @ip = ip
    @name = name
    @day = day
    @completed = completed
    @reached = reached
    @day_3_count = day_3_count
    @day_6_answers = day_6_answers
    @day_9_twister = day_9_twister
    @day_11_history = day_11_history
  end

  def complete
    @completed = true
  end

  def next
    @day += 1
    @reached = DateTime.now
    @completed = false
  end

  def day_3_visit
    @day_3_count += 1
  end

  private

  def self.stringify(val)
    "'#{val}'"
  end

  def self.serialize(peep)
      props = {}
      peep.instance_variables.each do |v|
        val = peep.instance_variable_get v
        if val.is_a?(String) || val.is_a?(DateTime) || val.is_a?(Time)
          val = self.stringify(val)
        end
        if val == nil
          val = "NULL"
        end
        props[v.to_s.delete("@").to_sym] = val
      end
      props
  end

end

class PeepNotFound < StandardError
end
