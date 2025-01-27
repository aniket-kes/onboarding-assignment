class Roll
  attr_accessor :num_of_dice, :player, :values, :cal_score, :non_scoring_dice

  def initialize(num_of_dice, player)
    @num_of_dice = num_of_dice
    @player = player
    @values = []
    @cal_score = 0
    @non_scoring_dice = @num_of_dice
  end
  
  def roll
  
    idx = 0

    while idx < num_of_dice
      values << rand(1..6)
      idx += 1
    end

    puts "Player #{player.id} rolls: #{values}"
    calc()
  end

  def calc
  
    counts = Hash.new(0)
    values.each { |value| counts[value] += 1 }

    @cal_score = 0
    # puts "Counts #{@num_of_dice} and #{@non_scoring_dice}"
    @non_scoring_dice = @num_of_dice
  
    counts.each do |item, count|
      if count >= 3
        if item == 1
          @cal_score += 1000
        else
          @cal_score += item * 100
        end
        @non_scoring_dice -= 3
        count -= 3
      end

      @cal_score += count * 100 if item == 1
      @cal_score += count * 50 if item == 5
      @non_scoring_dice -= count if item == 1 || item == 5
      # puts "Non scoring dice: #{@non_scoring_dice}"

    end
    puts "Score in this round: #{@cal_score}"
    return cal_score
  end
    

end
