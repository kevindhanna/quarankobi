module Day12
  def day_12(ip, name, code)
    expected = "-.-- ...- ... .-. / ...- ..-. / -.-. -... ...- .- --. -.-- .-. ..-. ..-. / --- .... --. / -. --. / -.-- .-. -. ..-. --. / .-.. -... .... / -. . .-. / -... .... --. / -... ... / -.. .... -. . -. .- --. ...- .- .-.".delete(" ").delete('/')
    correct = code && (code.delete(" ").delete("/").delete("%2F") == expected)
    if correct
      DB.complete(ip, 12)
    end

    erb :day_12, locals: {name: name, correct: correct, incorrect: !correct && code}
  end
end
