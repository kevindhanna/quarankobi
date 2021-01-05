module Day5
  def day_5(user)
    kj = params['kj']
    if kj
      kj = params['kj'].delete(",")
    end
    kj = kj.to_i || nil
    if kj == 5710 && @user.day == 5
      user.complete
      Peep.save(user)
    end
    erb :day_5, locals: {name: @user.name, completed: user.completed || user.day > 5, kj: kj}
  end
end
