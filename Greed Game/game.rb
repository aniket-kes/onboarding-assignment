require('./player.rb')
require('./turn.rb')
require('./roll.rb')

class Game

  def initialize(num_players)
    @players = []
    @last_round = false

    num_players.times do |i|
      @players << Player.new(i + 1)
    end
  end

  def play
    idx = 0
    while (!@last_round)
      puts "Turn #{idx + 1}"
      puts "-------"
      @players.each do |player|
        player_turn(player)
      end
      
      player = @players.max_by { |player| player.score }

      if player.score >= 3000
        @last_round = true
        break
      end

      idx += 1
    end

    puts "Yo this is the final round of this mid game"
    @players.each do |player|
      player_turn(player)
    end

    # Declaring the winner
    winner = @players.max_by { |player| player.score }
    puts "Player #{winner.id} wins with a score of #{winner.score}"
    puts "End Game"

  end

  def player_turn(player)
    turn = Turn.new(player)
    turn.start()
    
    puts "\n\n"	

    puts "Press enter\n" #Added so that the player can see the score before the next player's turn
	gets()	
  end

end

print "Enter number of players: "
num_players = gets().chomp().to_i
game = Game.new(num_players)
game.play()

