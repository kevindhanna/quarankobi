module Day6
  CORRECT = {"1.1"=>false, "1.2"=>true, "1.3"=>false, "1.4"=>false, "2.1"=>true, "2.2"=>false, "2.3"=>true, "3.1"=>false, "3.2"=>true, "4.1"=>true, "4.2"=>true, "4.3"=>false, "4.4"=>true, "5.1"=>false, "5.2"=>false, "5.3"=>true}
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
