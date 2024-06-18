require 'pstore'

class Questionnaire
  STORE_NAME = "tendable.pstore"

  def initialize
    @store = PStore.new(STORE_NAME)
    @questions = {
      "q1" => "Can you code in Ruby?",
      "q2" => "Can you code in JavaScript?",
      "q3" => "Can you code in Swift?",
      "q4" => "Can you code in Java?",
      "q5" => "Can you code in C#?"
    }.freeze
  end

  def do_prompt
    answers = {}

    @questions.each do |question_key, question_text|
      print "#{question_text} (Yes/No): "
      answer = gets.chomp.downcase
      unless ["yes", "no", "y", "n"].include?(answer)
        puts "Invalid input. Please enter Yes or No."
        redo # restart the loop
      end
      answers[question_key] = answer
    end

    @store.transaction do
      @store[:answers] ||= []
      @store[:answers] << answers
    end

    answers
  end

  def calculate_rating(answers)
    total_questions = @questions.size
    yes_count = answers.count { |_, answer| ["yes", "y"].include?(answer.downcase) }
    (yes_count.to_f / total_questions * 100).round(2)
  end

  def do_report
    all_answers = @store.transaction { @store[:answers] || [] }

    all_answers.each_with_index do |answers, index|
      rating = calculate_rating(answers)
      puts "Run #{index + 1}: Rating #{rating}%"
    end

    if !all_answers.empty?
      total_ratings = all_answers.map { |answers| calculate_rating(answers) }
      average_rating = (total_ratings.sum / total_ratings.size).round(2)
      puts "Average Rating: #{average_rating}%"
    else
      puts "No runs recorded yet."
    end
  end
end

# Main execution starts here
if __FILE__ == $PROGRAM_NAME
  questionnaire = Questionnaire.new

  loop do
    questionnaire.do_prompt
    questionnaire.do_report

    print "Do you want to run the survey again? (yes/no): "
    answer = gets.chomp.downcase
    break unless ["yes", "y"].include?(answer)
  end
end
