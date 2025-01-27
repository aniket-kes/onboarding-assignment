require 'rspec'
require_relative '../turn'
require_relative '../player'
require_relative '../roll'
RSpec.describe Turn do
  let(:player) { Player.new(1) }
  let(:turn) { Turn.new(player) }
  let(:roll_double) { instance_double("Roll") }

  describe "#initialize" do
    it "initializes the player correctly" do
      expect(turn.player).to eq(player)
    end

    it "sets the initial turn_score to 0" do
      expect(turn.turn_score).to eq(0)
    end

    it "sets the initial num_of_dice to 5" do
      expect(turn.num_of_dice).to eq(5)
    end
  end

  describe "#start" do
    before do
      # Mocking the Roll instance to avoid random behavior and control the return values
      allow(Roll).to receive(:new).and_return(roll_double)
    end

    it 'ends the turn if the roll score is 0' do
      roll = instance_double("Roll", cal_score: 0, non_scoring_dice: 5)
      allow(Roll).to receive(:new).and_return(roll)
      expect(roll).to receive(:roll)
      expect(turn).to receive(:turn_end)
      turn.start
      expect(turn.turn_score).to eq(0)
    end

    it 'asks for choice if the roll score is not 0' do
      roll = instance_double("Roll", cal_score: 100, non_scoring_dice: 3)
      allow(Roll).to receive(:new).and_return(roll)
      expect(roll).to receive(:roll)
      expect(turn).to receive(:ask_choice)
      turn.start
    end
  end

  describe "#ask_choice" do
    before do
      allow(turn).to receive(:gets).and_return('y')
    end

    it "calls start when user chooses to roll again" do
      allow(turn).to receive(:start)  # Mock start to avoid recursion in tests

      turn.ask_choice

      expect(turn).to have_received(:start)
    end

    it "ends the turn when user chooses 'n'" do
      allow(turn).to receive(:turn_end)

      allow(turn).to receive(:gets).and_return('n')  
      turn.ask_choice

      expect(turn).to have_received(:turn_end)
    end

    it "repeats if an invalid choice is given" do
      # Simulate invalid input followed by valid input
      allow(turn).to receive(:gets).and_return('z', 'n')
      allow(turn).to receive(:turn_end)

      turn.ask_choice

      expect(turn).to have_received(:turn_end)
    end
  end

  describe "#turn_end" do
    context "when the turn score is greater than or equal to 300" do
      it "marks the player as eligible and adds score to the player" do
        turn.turn_score = 350
        allow(player).to receive(:add_to_score)

        turn.turn_end

        expect(player).to have_received(:add_to_score).with(350)
        expect(player.eligible).to be(true)
      end
    end

    context "when the turn score is less than 300" do
      it "does not mark the player as eligible or add score" do
        turn.turn_score = 200
        allow(player).to receive(:add_to_score)

        turn.turn_end

        expect(player).not_to have_received(:add_to_score)
        expect(player.eligible).to be(false)
      end
    end
  end
end