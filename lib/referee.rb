# validates moves and checks for a winner

class Referee
  def initialize(board)
    @board = board
  end

  def valid_input?(input, player)
    # add error handling in the future (print out the issue)

    return false if input.nil? || !input.is_a?(Array) || input[2].is_a?(String)

    return false unless input[0].match?(/[rnbqkp]/) && input[0].length == 1

    return false unless input[1].to_s.length == 1 && input[1].to_s.match?(/\d/)
    return false unless input[2].to_s.length == 1 && input[2].to_s.match?(/\d/)

    if input.length == 4
      return false unless input[3].match?(/[a-h]/) || input[3].to_i.between?(0, 7)
      return false unless input[3].to_s.length == 1
    end

    valid_target?([input[1], input[2]], player.color)
  end

  def valid_target?(target, color)
    return false unless target[0].between?(0, 7) && target[1].between?(0, 7)

    # You cant take your own pieces
    target_piece = @board[target[0]][target[1]]
    return false if target_piece != "_" && target_piece.color == color

    true
  end

  def possible_move(input, player)
    piece_name = input[0]

    target = [input[1], input[2]]

    pieces = []
    # Find the piece
    if input.length == 4
      column = input[3].is_a?(String) ? LETTER_TO_NUMBER.index(input[3]) : nil
      row = input[3].is_a?(Integer) ? input[3] : nil
      pieces = find_matching_pieces(piece_name, player.color, column, row)
    else
      pieces = find_matching_pieces(piece_name, player.color)
    end

    pieces.each do |piece|
      next unless can_move_to_target?(piece, target)

      return piece unless moving_into_check?(piece, target)
    end
    false
  end

  def can_move_to_target?(piece, target)
    x = piece.pos[0]
    y = piece.pos[1]

    piece_name = piece.piece_name

    # Pawns have seperate moves for white or black colors, so we make sure to get the correct color if its a pawn
    moves = piece_name == "pawn" ? PIECE_MOVES["pawn"][piece.color] : PIECE_MOVES[piece_name]

    moves.each_with_index do |move, index|
      # Pawn can only move diagonally to capture another piece.
      next if piece_name == "pawn" && @board[target[0]][target[1]] == "_" && [1, 2].include?(index)
      # Pawn can only move 2 space if it's their first move
      next if piece_name == "pawn" && piece.times_moved > 0 && index == 0 # rubocop:disable Style/NumericPredicate

      # Move must stay within the board
      new_x = x + move[0]
      new_y = y + move[1]

      next unless new_x.between?(0, 7) && new_y.between?(0, 7)

      next if moving_over_piece?(move, x, y, piece_name, target)

      return true if target == [new_x, new_y]
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

  def moving_into_check?(piece, target)
    king = find_king(piece.color)

    original_pos = piece.pos
    piece_at_target = @board[target[0]][target[1]]

    # If we are moving the king, we should pass the target position.
    king_position = king.pos
    if king.piece_name == piece.piece_name
      king_position = target
    else
      # We must 'fake' the position of the piece we're moving to accurately show whether
      # moving to the target would result in the king being checked or not.

      @board[target[0]][target[1]] = piece
      @board[original_pos[0]][original_pos[1]] = "_"
    end
    in_check = king_in_check?(king.color, king_position)
    # If we 'faked' the pieces position, we must revert it back to its original position.
    @board[target[0]][target[1]] = piece_at_target
    @board[original_pos[0]][original_pos[1]] = piece

    if in_check
      puts "Cannot move king into check!"
      return true
    end
    false
  end

  def king_in_check?(king_color, king_position)
    # Loop through every piece that is an opposite color
    Piece.pieces.each do |piece|
      next if piece.color == king_color

      # Check all possible moves to see if they lead to the king's position without moving over another piece.
      return true if can_move_to_target?(piece, king_position)
    end
    false
  end

  def check_winner(player)
    # If opposite color king is checked
    # Check every valid move to see if king is in check after making the move.
    # If every valid move results in being checked, its checkmate
    king = find_king(player.color == "white" ? "black" : "white")

    return false unless king_in_check?(king.color, king.pos)

    # Loop through every move
    # If king is not in check after move then return player as winner

    Piece.pieces.each do |piece|
      next unless piece.color == king.color

      piece_name = piece.piece_name

      moves = piece_name == "pawn" ? PIECE_MOVES["pawn"][piece.color] : PIECE_MOVES[piece_name]

      original_pos = piece.pos

      moves.each_with_index do |move, index|
        new_x = piece.pos[0] + move[0]
        new_y = piece.pos[1] + move[1]

        target = [new_x, new_y]

        # Pawn can only move diagonally to capture another piece.
        next if piece_name == "pawn" && @board[target[0]][target[1]] == "_" && [1, 2].include?(index)
        # Pawn cannnot move 2 space unless its the first turn
        next if piece_name == "pawn" && piece.times_moved > 0 && index == 0 # rubocop:disable Style/NumericPredicate

        next unless valid_target?(target, piece.color)

        # Fake the move in order to accurately use king_in_check?
        piece_at_target = @board[new_x][new_y]
        @board[new_x][new_y] = piece

        king_position = king.pos
        king_position = target if piece_name == "king"

        in_check = king_in_check?(king.color, king_position)
        # Revert move.
        @board[original_pos[0]][original_pos[1]] = piece
        @board[new_x][new_y] = piece_at_target

        return false unless in_check
      end
    end

    player
  end
end
