require_relative "display"

class Player
  include Display
  attr_reader :color, :rounds_won

  def initialize(color, rounds_won = 0)
    @color = color
    @rounds_won = rounds_won
  end
end
