module Day2
  def day_2(user)
    score = params['score']
    if score
      score = params['score'].delete(",")
    end
    score = score.to_i || nil
    if score >= 15000 && !user.completed
      user.complete
      Peep.save(user)
    end
    haml :day_2, locals: {name: user.name, completed: user.completed || user.day > 2, score: score}
  end
end
