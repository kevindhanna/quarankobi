module Day11
  def day_11(user, code)
    if code && code.delete(' ').delete(',').downcase == 'bmo' && user.day == 11
      user.complete
      Peep.save(user)
    end

    erb :day_11, locals: {name: user.name, completed: user.day > 11 || user.completed, code: code}
  end
end
