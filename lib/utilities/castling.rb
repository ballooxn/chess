require_relative "../referee"
require_relative "../pieces/piece"

module Castle
  def self.castle(color, type, board, referee)
    p "test"
    king = Piece.find_king(color)
    target = get_target(king, type)
    rook_position = get_rook(king, type)
    rook = board[rook_position[0]][rook_position[1]]
    p rook

    return false unless can_castle?(king, target, rook, board, type, referee)

    new_rook_position = type == "oo" ? [king.pos[0], 5] : [king.pos[0], 3]

    [[king, target], [rook, new_rook_position]]
  end

  def self.can_castle?(king, target, rook, board, type, referee)
    return false unless king.times_moved.zero?

    unless rook != "_" && rook.piece_name == "rook" &&
           rook.times_moved.zero? && rook.color == king.color
      return false
    end

    return false if referee.moving_over_piece?(type == "oo" ? [0, 2] : [0, -2],
                                               king.pos[0], king.pos[1], "king", target)

    return false if referee.moving_into_check?(king, target)

    true
  end

  def self.get_target(king, type)
    type == "oo" ? [king.pos[0], 6] : [king.pos[0], 2]
  end

  def self.get_rook(king, type)
    type == "oo" ? [king.pos[0], 7] : [king.pos[0], 0]
  end
end
