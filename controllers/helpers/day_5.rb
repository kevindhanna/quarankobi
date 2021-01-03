module Day5
  def day_5(name, completed)
    kj = params['kj']
    if kj
      kj = params['kj'].delete(",")
    end
    kj = kj.to_i || nilp
    if kj == 5710
      DB.complete(request.ip, 5)
      completed = true
    end
    erb :day_5, locals: {name: name, completed: completed, kj: kj}
  end
end
