require_relative "utilities/display"
require_relative "pieces/piece"
require_relative "pieces/piece_moves"
require_relative "player"
require_relative "referee"

class Game
  include Display
  include PossibleMoves

  LETTER_TO_NUMBER = %w[a b c d e f g h].freeze
  LETTER_TO_PIECE = { "p" => "pawn", "n" => "knight", "k" => "king", "b" => "bishop", "q" => "queen",
                      "r" => "rook" }.freeze

  def initialize(board = nil)
    @player1 = Player.new("white")
    @player2 = Player.new("black")

    @winner = false

    @board = board.nil? ? setup_board : board

    @referee = Referee.new(@board)

    @num_moves = 0
  end

  def start_game
    Display.intro
    game_loop
  end

  def game_loop
    curr_plr = @player2
    Display.display_board(@board)
    until @winner

      curr_plr = curr_plr == @player2 ? @player1 : @player2

      input = curr_plr.player_input(@referee)
      piece_to_move = input[0]
      target = input[1]

      move_piece(piece_to_move, target)
      Display.display_board(@board)

      @winner = @referee.check_winner(curr_plr)
    end
    end_game
  end

  def end_game
    case @winner
    when "stalemate"
      Display.stalemate(@num_moves)
    when "50"
      Display.fifty_move_rule
    else
      Display.checkmate(@winner.color, @num_moves)
      @winner.rounds_won += 1
    end
    Display.play_again?
    answer = gets.chomp.downcase
    answer == "y" ? start_game : exit
  end

  def move_piece(piece, target)
    original_x = piece.pos[0]
    original_y = piece.pos[1]

    @board[original_x][original_y] = "_"

    overwritten_piece = @board[target[0]][target[1]]
    if overwritten_piece != "_"

      # remove piece from pieces array
      Piece.pieces.delete(overwritten_piece)
    end

    @board[target[0]][target[1]] = piece

    piece.pos = target
    piece.times_moved += 1

    @num_moves += 1
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
