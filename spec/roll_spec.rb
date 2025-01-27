require 'rspec'
require_relative '../roll'
require_relative '../player'

RSpec.describe Roll do
  let(:player) { Player.new(1) }
  let(:roll) { Roll.new(5, player) }

  describe '#initialize' do
    it 'initializes with num_of_dice, player, values, cal_score, and non_scoring_dice' do
      expect(roll.num_of_dice).to eq(5)
      expect(roll.player).to eq(player)
      expect(roll.values).to eq([])
      expect(roll.cal_score).to eq(0)
      expect(roll.non_scoring_dice).to eq(5)
    end

    it 'raises an error if num_of_dice is less than 1' do
      expect { Roll.new(0) }.to raise_error(ArgumentError)
    end
  end

  describe '#roll' do
    it 'rolls the dice and populates values' do
      roll.roll
      expect(roll.values.size).to eq(5)
      expect(roll.values).to all(be_between(1, 6))
    end

    it 'prints the rolled values' do
      expect { roll.roll }.to output(/Player 1 rolls: \[.*\]/).to_stdout
    end

    it 'rolls the dice with controlled values (mocking rand)' do
      allow(roll).to receive(:rand).and_return(1)
      roll.roll
      expect(roll.values).to eq([1, 1, 1, 1, 1]) # all ones because we mocked `rand`
    end
  end

  describe '#calc' do
    it 'calculates the score and non_scoring_dice' do
      roll.values = [1, 1, 1, 5, 2]
      roll.calc
      expect(roll.cal_score).to eq(1050)
      expect(roll.non_scoring_dice).to eq(1)
    end

    it 'calculates the score correctly for different values' do
      roll.values = [2, 3, 4, 6, 6]
      roll.calc
      expect(roll.cal_score).to eq(0)
      expect(roll.non_scoring_dice).to eq(5)
    end

    it 'calculates the score for a single 1' do
      roll.values = [1, 2, 3, 4, 4]
      roll.calc
      expect(roll.cal_score).to eq(100)  
      expect(roll.non_scoring_dice).to eq(4)  
    end

    it 'calculates the score for a single 5' do
      roll.values = [5, 2, 3, 4, 6]
      roll.calc
      expect(roll.cal_score).to eq(50)  
      expect(roll.non_scoring_dice).to eq(4)  
    end

    it 'calculates the score for three 2’s' do
      roll.values = [2, 2, 2, 4, 3]
      roll.calc
      expect(roll.cal_score).to eq(200) 
      expect(roll.non_scoring_dice).to eq(2) 
    end

    it 'calculates the score for three 5’s' do
      roll.values = [5, 5, 5, 1, 2]
      roll.calc
      expect(roll.cal_score).to eq(600) 
      expect(roll.non_scoring_dice).to eq(1)  
    end

    it 'calculates the score for a mix of 1’s and 5’s' do
      roll.values = [1, 1, 1, 5, 5]
      roll.calc
      expect(roll.cal_score).to eq(1100)
      expect(roll.non_scoring_dice).to eq(0)  
    end
  end
end