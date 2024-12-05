require_relative "referee"
require_relative "pieces/piece"
require_relative "utilities/display"

class Engine
  include Display

  attr_reader :color

  def initialize(color, referee)
    @color = color
    @referee = referee
  end

  def choose_move
    # Pick a random piece
    # Pick a random move for that piece
    # Check if the move is valid
    # Move piece.
    Display.computer_move
    valid_move = false
    until valid_move
      pieces = shuffle_pieces
      target = nil
      pieces.each do |piece|
        target = random_move(piece)
        return [piece, target] if target
      end
    end
    puts "Error calculating move."
    nil
  end

  def shuffle_pieces
    Piece.pieces.select { |p| p.color == @color }.shuffle
  end

  def random_move(piece)
    moves = Piece.get_moves(piece.piece_name, @color).shuffle
    moves.each_with_index do |move, index|
      p move
      target = [(piece.pos[0] + move[0]), (piece.pos[1] + move[1])]
      next unless @referee.valid_target?(target, @color) &&
                  !@referee.moving_over_piece?(move, piece.pos[0], piece.pos[1], piece.piece_name,
                                               target) && !@referee.moving_into_check?(piece, target, false)

      return false if piece.piece_name == "pawn" && !@referee.can_move_pawn?(piece.times_moved, target, index)

      return target
    end
    nil
  end
end
