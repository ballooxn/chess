require_relative "display"
require_relative "pieces/piece"
require_relative "pieces/piece_moves"
require_relative "player"

class Game
  include Display

  LETTER_TO_NUMBER = %w[a b c d e f g h]

  def initialize(board = Array.new(8) { Array.new(8, "_") })
    @board = board
    @player1 = Player.new("white")
    @player2 = Player.new("black")

    @winner = false
  end

  def start_game
    Display.intro
    set_board
    game_loop
  end

  def game_loop
    curr_plr = @player2
    until @winner
      curr_plr = curr_plr == @player2 ? @player1 : @player2
      player_input(curr_plr)
    end
  end

  def player_input(player)
    # in the future, allow player to input just 'd2' to move a pawn instead of 'pd2'

    # The first part of input is the piece, second is position to move to.
    # Display.player_input(player.color)
    input = nil
    until valid_input?(input)
      input = gets.chomp.split("", 3)
      input[1] = LETTER_TO_NUMBER.index(input[1].downcase) if input[1].match?(/[a-h]/)
      input[2] = input[2].to_i
    end
  end

  def valid_input?(input)
    return false if input.nil? || !input.is_a?(Array)

    return false unless input[0].match?(/[rnbqkpRNBQKP]/) && input[0].length == 1

    return false unless input[1].to_s.length == 1 && input[1].to_s.match?(/\d/)
    return false unless input[2].to_s.length == 1 && input[2].to_s.match?(/\d/)

    return false unless input[1][0].between?(0, 7) && input[2].between?(0, 7)

    # Check if input is reachable via a possible move.
    return false unless possible_move?(input)

    true
  end

  def possible_move?
  end

  def game_over?
  end

  def set_board
    @board[0][0] = Piece.new("white", "rook")
    @board[0][1] = Piece.new("white", "knight")
    @board[0][2] = Piece.new("white", "bishop")
    @board[0][3] = Piece.new("white", "queen")
    @board[0][4] = Piece.new("white", "king")
    @board[0][5] = Piece.new("white", "bishop")
    @board[0][6] = Piece.new("white", "knight")
    @board[0][7] = Piece.new("white", "rook")

    @board[7][0] = Piece.new("black", "rook")
    @board[7][1] = Piece.new("black", "knight")
    @board[7][2] = Piece.new("black", "bishop")
    @board[7][3] = Piece.new("black", "queen")
    @board[7][4] = Piece.new("black", "king")
    @board[7][5] = Piece.new("black", "bishop")
    @board[7][6] = Piece.new("black", "knight")
    @board[7][7] = Piece.new("black", "rook")

    8.times do |i|
      @board[1][i] = Piece.new("white", "pawn")
      @board[6][i] = Piece.new("black", "pawn")
    end
  end
end
