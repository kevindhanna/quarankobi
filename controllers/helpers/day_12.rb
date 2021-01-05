module Day12
  def day_12(user, code)
    expected = "-.-- ...- ... .-. / ...- ..-. / -.-. -... ...- .- --. -.-- .-. ..-. ..-. / --- .... --. / -. --. / -.-- .-. -. ..-. --. / .-.. -... .... / -. . .-. / -... .... --. / -... ... / -.. .... -. . -. .- --. ...- .- .-.".delete(" ").delete('/')
    correct = code && (code.delete(" ").delete("/").delete("%2F") == expected)
    if correct && user.day == 12
      user.complete
      Peep.save(user)
    end

    erb :day_12, locals: {name: user.name, correct: user.completed || user.day > 12, incorrect: !correct && code}
  end
end
