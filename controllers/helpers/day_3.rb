module Day3
  def day_3(user)
    # increment the visit counter
    user.day_3_count += 1
    Peep.save(user)
    # get total visits
    # number of refreshes until message + message.length
    if user.day_3_count > 51 && user.day == 3
      user.complete
      Peep.save(user)
    end

    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    message.push("did you get all that?")
    haml :day_3, locals: {count: user.day_3_count, message: message, name: user.name}
  end
end
