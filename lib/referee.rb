# validates moves and checks for a winner

require_relative "pieces/piece"
require_relative "pieces/piece_moves"

class Referee
  include PossibleMoves

  LETTER_TO_NUMBER = %w[a b c d e f g h].freeze
  LETTER_TO_PIECE = { "p" => "pawn", "n" => "knight", "k" => "king", "b" => "bishop", "q" => "queen",
                      "r" => "rook" }.freeze
  PIECE_MOVES = {
    "pawn" => { "white" => WHITE_PAWN_MOVES, "black" => BLACK_PAWN_MOVES },
    "knight" => KNIGHT_MOVES,
    "bishop" => BISHOP_MOVES,
    "king" => KING_MOVES,
    "queen" => QUEEN_MOVES,
    "rook" => ROOK_MOVES
  }.freeze

  ERRORS = {
    "invalid_piece" => "Invalid piece. Please use one of the following: #{LETTER_TO_PIECE.keys.join(', ')}",
    "invalid_target" => "Invalid target. Please use a valid target on the board.",
    "invalid_move" => "None of your pieces can move there. Please try again."
  }.freeze

  def initialize(board)
    @board = board
  end

  def valid_input?(input, color)
    return false if input.nil? || !input.is_a?(Array) || input[2].is_a?(String)

    unless input[0].match?(/[rnbqkp]/)
      puts ERRORS["invalid_piece"]
      return false
    end

    unless input[1].between?(0, 7) && input[2].between?(0, 7)
      puts ERRORS["invalid_target"]
      return false
    end

    return false if input.length == 4 && !(input[3].match?(/[a-h]/) || input[3].to_i.between?(0, 7))

    valid_target?([input[1], input[2]], color)
  end

  def valid_target?(target, color)
    return false unless in_bounds?(target[0], target[1])

    # You cant take your own pieces
    target_piece = @board[target[0]][target[1]]
    return false if target_piece != "_" && target_piece.color == color

    true
  end

  def piece_to_move(input, color)
    piece_name = input[0]
    target = [input[1], input[2]]

    pieces = Piece.find_matching_pieces(piece_name, color,
                                        input[3].is_a?(String) ? LETTER_TO_NUMBER.index(input[3]) : nil,
                                        input[3].is_a?(Integer) ? input[3] : nil)
    pieces.find { |piece| can_move_to_target?(piece, target) && !moving_into_check?(piece, target) }
  end

  def check_winner(player)
    king = Piece.find_king(player.color == "white" ? "black" : "white")
    opposite_king = Piece.find_king(player.color == "white" ? "white" : "black")

    return player if checkmate?(king)

    return "stalemate" if stalemate?(opposite_king)

    nil
  end

  def stalemate?(king)
    return false if king_in_check?(king.color, king.pos)

    # Check all pieces of the opposite king's color to see if any valid move exist
    # Return false if there is any possible move, true if there isn't.
    Piece.pieces.each do |piece|
      next unless piece.color == king.color

      moves = Piece.get_moves(piece.piece_name, piece.color)
      # Return true if there is any possible move
      moves.each do |move|
        target = [(piece.pos[0] + move[0]), (piece.pos[1] + move[1])]
        # if the move is valid and the piece can move to the target
        next unless valid_target?(target, piece.color)
        next if moving_over_piece?(move, piece.pos[0], piece.pos[1], piece.piece_name, target)

        next if moving_into_check?(piece, target, true)

        return false
      end
    end

    true
  end

  def checkmate?(king)
    return false unless king_in_check?(king.color, king.pos)

    # Check all pieces of the king's color to see if any valid move exists
    Piece.pieces.each do |piece|
      next unless piece.color == king.color

      piece_name = piece.piece_name
      moves = Piece.get_moves(piece_name, piece.color)
      original_pos = piece.pos

      moves.each_with_index do |move, index|
        new_x = piece.pos[0] + move[0]
        new_y = piece.pos[1] + move[1]

        target = [new_x, new_y]

        next if piece_name == "pawn" && !can_move_pawn?(piece.times_moved, target, index)

        next unless valid_target?(target, piece.color)

        # Fake the move in order to accurately use king_in_check?
        piece_at_target = @board[new_x][new_y]
        @board[new_x][new_y] = piece

        king_position = piece.piece_name == "king" ? target : king.pos

        in_check = king_in_check?(king.color, king_position)
        # Revert move.
        @board[original_pos[0]][original_pos[1]] = piece
        @board[new_x][new_y] = piece_at_target

        return false unless in_check
      end
    end
    true
  end

  def can_move_to_target?(piece, target)
    x, y = piece.pos
    piece_name = piece.piece_name

    moves = Piece.get_moves(piece_name, piece.color)

    moves.each_with_index do |move, index|
      next if piece_name == "pawn" && !can_move_pawn?(piece.times_moved, target, index)

      # Move must stay within the board
      new_x = x + move[0]
      new_y = y + move[1]

      return true if in_bounds?(new_x, new_y) && target == [new_x, new_y] &&
                     !moving_over_piece?(move, x, y, piece_name, target)
    end

    false
  end

  def moving_over_piece?(move, curr_x, curr_y, name, target)
    move_x = move[0]
    move_y = move[1]

    # Knights jump over pieces, so we dont check for them
    return false if name == "knight"

    direction_x = move_x.positive? ? 1 : -1
    direction_y = move_y.positive? ? 1 : -1

    if move_x.abs.positive?
      move_x.abs.times do |_i|
        curr_x += direction_x
        # Only go up/down if there if we can.
        if move_y.abs.positive?
          curr_y += direction_y
          move_y -= direction_y
        end

        return true if @board[curr_x][curr_y] != "_" && target != [curr_x, curr_y]
      end
    else
      move_y.abs.times do |_i|
        curr_y += direction_y

        if move_x.abs.positive?
          curr_x += direction_x
          move_x -= direction_x
        end

        return true if @board[curr_x][curr_y] != "_" && target != [curr_x, curr_y]
      end
    end
    false
  end

  def moving_into_check?(piece, target, checking_stalemate_or_engine = false)
    king = Piece.find_king(piece.color)

    original_pos = piece.pos
    piece_at_target = @board[target[0]][target[1]]

    # If we are moving the king, we should pass the target position.
    king_position = piece.piece_name == "king" ? target : king.pos

    unless piece.piece_name == "king"
      # We must 'fake' the position of the piece we're moving to accurately show whether
      # moving to the target would result in the king being checked or not.

      @board[target[0]][target[1]] = piece
      @board[original_pos[0]][original_pos[1]] = "_"
    end

    in_check = king_in_check?(king.color, king_position)

    # Revert the "faked" move
    @board[target[0]][target[1]] = piece_at_target
    @board[original_pos[0]][original_pos[1]] = piece

    puts "Cannot move into/ignore check!" if in_check && !checking_stalemate_or_engine
    in_check
  end

  def king_in_check?(king_color, king_position)
    # Check all possible moves to see if they lead to the king's position without moving over another piece.
    Piece.pieces.any? do |piece|
      piece.color != king_color && can_move_to_target?(piece, king_position)
    end
  end

  def can_move_pawn?(times_moved, target, index)
    # Pawn can only move diagonally to capture another piece.
    return false if @board[target[0]][target[1]] == "_" && [1, 2].include?(index)

    return false if @board[target[0]][target[1]] != "_" && [0, 3].include?(index)

    # Pawn cannnot move 2 space unless its the first turn
    return false if times_moved > 0 && index == 0 # rubocop:disable Style/NumericPredicate

    true
  end

  def in_bounds?(x, y)
    x.between?(0, 7) && y.between?(0, 7)
  end
end
