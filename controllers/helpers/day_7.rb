module Day7
  def day_7(name, completed, answer)
    if answer
      answer = answer.delete(" ").delete("/").delete(",").downcase
    end
    if answer == "lbh"
      DB.complete(request.ip, 7)
      completed = true
    end
    erb :day_7, locals: {name: name, completed: completed}
  end
end
