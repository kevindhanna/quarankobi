module Day3
  def day_3(id, name, completed)
    # increment the visit counter
    DB.visit(id)
    # get total visits
    count = DB.visits(id)
    # number of refreshes until message + message.length
    if count > 51 && !completed
      DB.complete(id, 3)
    end
    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    message.push("did you get all that?")
    haml :day_3, locals: {count: count, message: message, name: name}
  end
end
