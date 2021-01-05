module Day2
  def day_2(name, completed)
    score = params['score']
    if score
      score = params['score'].delete(",")
    end
    score = score.to_i || nil
    if score >= 15000 && !completed
      DB.complete(session['uuid'], 2)
      completed = true
    end
    haml :day_2, locals: {name: name, completed: completed, score: score}
  end
end
