require_relative "display"
require_relative "pieces/piece"
require_relative "pieces/piece_moves"
require_relative "player"

class Game
  include Display
  include PossibleMoves

  LETTER_TO_NUMBER = %w[a b c d e f g h].freeze
  LETTER_TO_PIECE = { "p" => "pawn", "n" => "knight", "k" => "king", "b" => "bishop", "q" => "queen",
                      "r" => "rook" }.freeze
  PIECE_MOVES = { "pawn" => { "white" => WHITE_PAWN_MOVES, "black" => BLACK_PAWN_MOVES }, "knight" => KNIGHT_MOVES, "bishop" => BISHOP_MOVES,
                  "king" => KING_MOVES, "queen" => QUEEN_MOVES, "rook" => ROOK_MOVES }.freeze

  def initialize(board = nil)
    @player1 = Player.new("white")
    @player2 = Player.new("black")

    @winner = false

    @board = board.nil? ? setup_board : board
  end

  def start_game
    Display.intro
    game_loop
  end

  def game_loop
    curr_plr = @player2
    until @winner
      Display.display_board(@board)
      curr_plr = curr_plr == @player2 ? @player1 : @player2

      input = player_input(curr_plr)
      piece_to_move = input[0]
      target = input[1]

      move_piece(piece_to_move, target)
    end
  end

  def player_input(player)
    # in the future, allow player to input just 'd2' to move a pawn instead of 'pd2'

    # The first part of input is the piece, second and third is position to move to.
    Display.player_input(player.color)
    valid_move = false
    until valid_move

      input = gets.chomp.split("", 3)
      # reverse the numbers as the letters should be columns
      orig_input2 = input[2]
      input[2] = LETTER_TO_NUMBER.index(input[1].downcase) if input[1].match?(/[a-h]/)
      input[1] = orig_input2.to_i
      next unless valid_input?(input, player)

      piece_to_move = possible_move(input, player)
      return [piece_to_move, [input[1], input[2]]] if piece_to_move
    end
  end

  def valid_input?(input, player)
    # add error handling in the future (print out the issue)
    return false if input.nil? || !input.is_a?(Array)
    return false if input[2].is_a?(String)

    return false unless input[0].match?(/[rnbqkpRNBQKP]/) && input[0].length == 1

    return false unless input[1].to_s.length == 1 && input[1].to_s.match?(/\d/)
    return false unless input[2].to_s.length == 1 && input[2].to_s.match?(/\d/)

    return false unless input[1].between?(0, 7) && input[2].between?(0, 7)

    # Check if input is reachable in one turn

    return false if @board[input[1]][input[2]] != "_" && @board[input[1]][input[2]].color == player.color

    true
  end

  def possible_move(input, player)
    piece_name = LETTER_TO_PIECE[input[0]]
    moves = piece_name == "pawn" ? PIECE_MOVES[piece_name][player.color] : PIECE_MOVES[piece_name]
    target = [input[1], input[2]]

    Piece.pieces.each do |piece|
      next if piece.color != player.color || piece.piece_name != piece_name

      x = piece.pos[0]
      y = piece.pos[1]

      moves.each_with_index do |move, index|
        # Pawn can only move diagonally to capture another piece.
        next if piece_name == "pawn" && @board[target[0]][target[1]] == "_" && [1, 2].include?(index)
        # Pawn cannnot move 2 space unless its the first turn
        next if piece_name == "pawn" && piece.times_moved > 0 && index == 0 # rubocop:disable Style/NumericPredicate

        next unless (x + move[0]).between?(0, 7) && (y + move[1]).between?(0, 7)
        next if moving_over_piece?(move, x, y, piece_name, target)

        return piece if x + move[0] == target[0] && y + move[1] == target[1]
      end
    end
    false
  end

  def moving_over_piece?(move, curr_x, curr_y, name, target)
    move_x = move[0]
    move_y = move[1]
    return false if name == "knight"

    if move_x.abs >= 0
      move_x.abs.times do |_i|
        move_x.positive? ? curr_x += 1 : curr_x -= 1
        if move_y.abs.positive?
          if move_y.positive?
            curr_y += 1
            move_y -= 1
          else
            curr_y -= 1
            move_y += 1
          end
        end

        return true if @board[curr_x][curr_y] != "_" && target != [curr_x, curr_y]
      end
    else
      move_y.abs.times do |_i|
        move_y.positive? ? curr_y += 1 : curr_y -= 1
        if move_x.positive?
          if move_y.positive?
            curr_x += 1
            move_x -= 1
          else
            curr_x -= 1
            move_x += 1
          end
        end

        return true if @board[curr_x][curr_y] != "_" && target != [curr_x, curr_y]
      end
    end
    false
  end

  def game_over?
    # If king is checked
    # Check every valid move to see if king is in check after making the move.
    # If every valid move results in being checked, its checkmate
  end

  def move_piece(piece, target)
    orig_x = piece.pos[0]
    orig_y = piece.pos[1]

    @board[orig_x][orig_y] = "_"
    @board[target[0]][target[1]] = piece

    piece.pos = target
    piece.times_moved += 1
  end

  private

  def setup_board
    board = Array.new(8) { Array.new(8, "_") }

    board[0][0] = Piece.new("white", "rook", [0, 0])
    board[0][1] = Piece.new("white", "knight", [0, 1])
    board[0][2] = Piece.new("white", "bishop", [0, 2])
    board[0][3] = Piece.new("white", "queen", [0, 3])
    board[0][4] = Piece.new("white", "king", [0, 4])
    board[0][5] = Piece.new("white", "bishop", [0, 5])
    board[0][6] = Piece.new("white", "knight", [0, 6])
    board[0][7] = Piece.new("white", "rook", [0, 7])

    board[7][0] = Piece.new("black", "rook", [7, 0])
    board[7][1] = Piece.new("black", "knight", [7, 1])
    board[7][2] = Piece.new("black", "bishop", [7, 2])
    board[7][3] = Piece.new("black", "queen", [7, 3])
    board[7][4] = Piece.new("black", "king", [7, 4])
    board[7][5] = Piece.new("black", "bishop", [7, 5])
    board[7][6] = Piece.new("black", "knight", [7, 6])
    board[7][7] = Piece.new("black", "rook", [7, 7])

    8.times do |i|
      board[1][i] = Piece.new("white", "pawn", [1, i])
      board[6][i] = Piece.new("black", "pawn", [6, i])
    end
    board
  end
end
