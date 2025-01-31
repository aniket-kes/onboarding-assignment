class Turn
  attr_accessor :player, :turn_score, :num_of_dice

  def initialize(player)
    @player = player
    @turn_score = 0
    @num_of_dice = 5
  end

  def start
    roll = Roll.new(@num_of_dice, @player)
    roll.roll()
    
    if (roll.cal_score == 0)
			@turn_score = 0
			turn_end()
    else
      @num_of_dice = (@num_of_dice == 5 && roll.non_scoring_dice == 0) ? 5 : roll.non_scoring_dice #when all dice are scoring, reset the number of dice to 5
      @turn_score += roll.cal_score
      
      puts "Turn Score: #{@turn_score} "
      ask_choice()
    end
  end

  def ask_choice
    print "Do you want to roll the non-scoring #{num_of_dice} dices?(y/n): "
    choice = gets().chomp().to_s

    if(choice == 'y')
      start()
    elsif(choice == 'n')
      turn_end()
    else
      puts "Invalid choice, please choose again"
      ask_choice()
    end

  end

  def turn_end
    player.eligible = true if @turn_score >= 300
    player.add_to_score(@turn_score) if @player.eligible
    puts "Total Score: #{player.score} "
  end

end

