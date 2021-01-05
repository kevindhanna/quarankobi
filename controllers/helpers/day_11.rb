module Day11
  def day_11(name, completed, code)
    if code && code.delete(' ').delete(',').downcase == 'bmo' && !completed
      DB.complete(session['uuid'], 11)
      completed = true
    end

    erb :day_11, locals: {name: name, completed: completed, code: code}
  end
end
