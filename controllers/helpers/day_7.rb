module Day7
  def day_7(user, answer)
    if answer
      answer = answer.delete(" ").delete("/").delete(",").downcase
    end
    if answer == "lbh" && @user.day == 7
      @user.complete
      Peep.save(user)
    end
    erb :day_7, locals: {name: @user.name, completed: @user.completed || @user.day > 7}
  end
end
