class Player
  attr_accessor :id, :score, :eligible

  def initialize(id)
    @id = id
    @score = 0
    @eligible = false
  end
  
  def add_to_score(points)
    @score += points
  end

end

