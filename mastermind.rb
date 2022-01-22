require 'pry-byebug'

# add custom method to String class
class String
  def str_to_num_arr(str = self)
    str.split(//).map!(&:to_i)
  end
end

# this module contain method that checks the pattern input of codebreaker
module MasterMindPattern
  def check_pattern_input(pattern_input, code_pattern)
    pattern_input.map.with_index do |num, i|
      if num == code_pattern[i]
        code_pattern[i] = nil
        '+'
      elsif code_pattern.any?(num)
        code_pattern[code_pattern.index(pattern_input[i])] = nil
        '-'
      else
        'x'
      end
    end
  end
end

# Create a CodeMaker class, which randomly selects the secret color
class CodeMaker
  include MasterMindPattern
  attr_accessor :code_pattern

  def initialize
    @code_pattern = []
  end

  def create_pattern_computer(pattern)
    self.code_pattern = if pattern == 1
                          [*1..6].sample(4)
                        else
                          [*1..6, *1..6, *1..6, *1..6].sample(4)
                        end
    puts 'The codemaker has finished creating the code pattern.'
    code_pattern
  end

  def create_pattern_player
    puts 'Input the code (four digits and from 1 to 6 only) you want the computer to guess.'
    until code_pattern.length == 4 && code_pattern.str_to_num_arr.all? { |num| num.positive? && num < 7 }
      print 'Please input four numbers only and only from 1 to 6: '
      self.code_pattern = gets.chomp
    end
    code_pattern.str_to_num_arr
  end

  def feedback_pattern_input(pattern_input, code_pattern)
    check_pattern_input(pattern_input, code_pattern)
  end
end

# class of codebreaker
class CodeBreaker
  include MasterMindPattern
  attr_accessor :guess, :code_combinations, :counter

  def initialize
    initialize_all_possible_combination
  end

  def initialize_all_possible_combination
    @code_combinations = [*1111..6666]
    code_combinations.map!(&:to_s).reject! { |e| e.include?('0') }.delete('1122')
    code_combinations.unshift('1122')
  end

  def input_guess(condition)
    if condition == 1
      input_guess_computer
    else
      input_guess_player
    end
  end

  def input_guess_player
    print 'Input your guess: '
    self.guess = gets.chomp
    until guess.length == 4 && guess.split(//).map(&:to_i).all? { |num| num.positive? && num < 7 }
      print 'Please input four numbers only and only from 1 to 6: '
      self.guess = gets.chomp
    end
  end

  def input_guess_computer
    self.guess = code_combinations[0]
    puts "Computer input: #{guess}"
  end

  # Swaszek Mastermind Algorithm
  def computer_guess_algorithm(input_code, feedback_pattern)
    input_code.map!(&:to_s)
    code_combinations.select! do |code|
      code if feedback_pattern.sort == check_pattern_input(input_code, code.split(//)).sort
    end
  end
end

# this class defines the methods done in the Mastermind game
class Game
  attr_accessor :guess_counter, :code_breaker, :code_maker, :pattern, :pattern_input
  attr_reader :role

  def initialize
    @guess_counter = 12
    @code_breaker = CodeBreaker.new
    @code_maker = CodeMaker.new
    start_game
  end

  def decrement_guess_counter
    self.guess_counter -= 1
  end

  def show_title
    puts '-------------------'
    puts '|Number Mastermind|'
    puts '-------------------'
  end

  def show_instruction
    puts ''
    puts 'Both the computer and the player can be a codebreaker or codemaker depending on the chosen setting.'
    puts 'Codemaker is the one who will create the code to be deciphered by the codebreaker.'
    puts 'Codebreaker is the one who will break the code made by the codemaker with a limit of 12 guesses.'
    puts ''
    puts '+ indicates that one of the numbers in the pattern is correct and is in right position.'
    puts '- indicates that one of the numbers in the pattern is correct but is in the wrong position.'
    puts 'x indicates that none of the numbers in the pattern has the correct color and position.'
    puts ''
  end

  def choose_role
    puts 'Type the role you want.'
    puts '1: You are the codemaker and computer is the codebreaker.'
    puts '2: You are the codebreaker and computer is the codemaker.'
    puts 'Invalid Input, choose only between 1 and 2.' until [1, 2].include?(@role = gets.chomp.to_i)
    puts ''
    create_pattern(role)
  end

  def create_pattern(role)
    if role == 2
      ask_duplicate_pattern
    else
      @pattern = code_maker.create_pattern_player
    end
  end

  def ask_duplicate_pattern
    puts 'Type the pattern you desire.'
    puts '1: Codemaker cannot choose duplicate numbers in the pattern to be guessed.'
    puts '2: Codemaker can choose duplicate numbers in the pattern to be guessed.'
    until [1, 2].include?(pattern_condition = gets.chomp.to_i)
      puts 'Invalid Input, choose only between 1 and 2.'
    end
    puts ''
    @pattern = code_maker.create_pattern_computer(pattern_condition)
  end

  def start_guess
    return show_result('lose') if guess_counter.zero?

    puts ''
    puts "You have #{guess_counter} remaining tries to guess the code."
    decrement_guess_counter
    code_breaker.input_guess(role)
    check_pattern
  end

  def check_pattern
    pattern_input = code_breaker.guess.str_to_num_arr
    validated_pattern = code_maker.feedback_pattern_input(pattern_input, pattern.clone).shuffle
    print "Clue: #{validated_pattern.join}\n"
    code_breaker.computer_guess_algorithm(pattern_input, validated_pattern) if role == 1
    return show_result('win') if validated_pattern.join == '++++'

    start_guess
  end

  def show_result(result)
    puts ''
    if result == 'win'
      puts 'Congratulations, you have correctly guessed the code!'
    else
      puts 'Ran out number of guesses. Better luck next time.'
    end
  end

  def start_game
    show_title
    show_instruction
    choose_role
    puts ''
    p pattern
    start_guess
  end
end

Game.new
