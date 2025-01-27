require_relative '../player'

RSpec.describe Player do
  let(:player1) { Player.new(1) }
  let(:player2) { Player.new(2) }
  let(:player3) { Player.new(3) }

  describe "#initialize" do
    it "sets the id correctly for player1" do
      expect(player1.id).to eq(1)
    end

    it "sets the initial score to 0 for player2" do
      expect(player2.score).to eq(0)
    end

    it "sets the initial eligibility to false for player3" do
      expect(player3.eligible).to be(false)
    end
  end

  describe "#add_to_score" do
    it "adds points to the score for player1" do
      player1.add_to_score(10)
      expect(player1.score).to eq(10)
    end

    it "does not affect player2 when adding points to player1" do
      player1.add_to_score(15)
      expect(player2.score).to eq(0) 
    end

    it "allows player3 to have a different score from player2" do
      player3.add_to_score(25)
      expect(player3.score).to eq(25)
      expect(player2.score).to eq(0)  # player2 still has score 0
    end

    it "adds multiple points correctly for all players" do
      player1.add_to_score(5)
      player2.add_to_score(10)
      player3.add_to_score(15)

      expect(player1.score).to eq(5)
      expect(player2.score).to eq(10)
      expect(player3.score).to eq(15)
    end
  end
end
