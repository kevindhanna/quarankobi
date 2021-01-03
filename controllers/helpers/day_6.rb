module Day6
  CORRECT = {"1.1"=>false, "1.2"=>true, "1.3"=>false, "1.4"=>false, "2.1"=>true, "2.2"=>false, "2.3"=>true, "3.1"=>false, "3.2"=>true, "4.1"=>true, "4.2"=>true, "4.3"=>false, "4.4"=>true, "5.1"=>false, "5.2"=>false, "5.3"=>true}

  def day_6(ip, name, params, redirect_url)
    answers = {}
    # see if they've visited before, if so populate answers for them
    # because I'm nice
    if params.length == 0
      params = DB.day_6_answers(request.ip)
      if params.length > 0
        redirect "#{redirect_url}?#{params}"
      end
    else
      DB.set_day_6_answers(ip, request.query_string)
      result, answers = validate_answers(params)
    end

    if result
      DB.complete(request.ip, 6)
    end

    erb :day_6, locals: {name: name, submitted: params.length > 0, result: result, answers: answers}
  end

  def validate_answers(answers)
    answers = symbolise(answers)
    result = compare(answers)

    [answers == CORRECT, result]
  end

  private

  def compare(answers)
    result = {}
    answers.each do |question, answer|
      result[question] = answer == CORRECT[question]
    end
    result
  end

  def symbolise(array)
    hash = {}
    array.each do |thing|
      hash[thing[0]] = thing[1] == "true"
    end
    hash
  end
end
