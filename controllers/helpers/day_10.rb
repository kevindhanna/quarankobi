module Day10
  def day_10(user, code)
    expected_morse = "-.-- ...- ... .-. / ...- ..-. / -.-. -... ...- .- --. -.-- .-. ..-. ..-. / --- .... --. / -. --. / -.-- .-. -. ..-. --. / .-.. -... .... / -. . .-. / -... .... --.".delete(" ").delete('/')
    expected_letters = "YVSR VF CBVAGYRFF OHG NG YRNFG LBH NER BHG".delete(" ").downcase
    if code
      code_morse = code.delete(" ").delete("/").delete("%2F").downcase
      code_letters = code.delete(" ").delete("/").downcase
    end

    correct = code_morse == expected_morse || code_letters == expected_letters
    if correct && user.day == 10
      user.complete
      Peep.save(user)
    end

    erb :day_10, locals: {name: user.name, correct: user.completed || user.day > 10, incorrect: !correct && code}
  end
end
