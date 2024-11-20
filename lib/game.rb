require_relative "display"
require_relative "pieces/piece"
require_relative "pieces/piece_moves"

class Game
  include Display
  def initialize(board = Array.new(8) { Array.new(8, "_") })
    @board = board
  end

  def start_game
  end
end
