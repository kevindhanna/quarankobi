module Day3
  def day_3(ip, name)
    # increment the visit counter
    DB.visit(ip)
    # get total visits
    count = DB.visits(ip)
    # number of refreshes until message + message.length
    if count > 51
      DB.complete(ip, 3)
    end
    message = "-.-./-.../...-/.-/--./-.--/.-./..-./..-.!".split("")
    message.push("did you get all that?")
    haml :day_3, locals: {count: count, message: message, name: name}
  end
end
