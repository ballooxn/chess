require_relative "display"

class Player
  include Display
  attr_reader :color, :rounds_won

  def initialize(color, rounds_won = 0)
    @color = color
    @rounds_won = rounds_won
  end

  def choose_color
    Display.choose_color
  end

  def player_input
    Display.player_input(@color)
    input = nil
    until valid_input?(input)

    end
  end
end
