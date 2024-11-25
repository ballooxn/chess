require_relative "display"
require_relative "pieces/piece"
require_relative "pieces/piece_moves"
require_relative "player"

class Game
  include Display
  include PossibleMoves

  LETTER_TO_NUMBER = %w[a b c d e f g h]
  LETTER_TO_PIECE = { "p" => "pawn", "n" => "knight", "k" => "king", "b" => "bishop", "q" => "queen", "r" => "rook" }
  PIECE_MOVES = { "pawn" => { "white" => WHITE_PAWN_MOVES, "black" => BLACK_PAWN_MOVES }, "knight" => KNIGHT_MOVES, "bishop" => BISHOP_MOVES,
                  "king" => KING_MOVES, "queen" => QUEEN_MOVES, "rook" => ROOK_MOVES }

  def initialize(board = Array.new(8) { Array.new(8, "_") })
    @board = board
    @player1 = Player.new("white")
    @player2 = Player.new("black")

    @pieces = []

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

    # The first part of input is the piece, second and third is position to move to.
    # Display.player_input(player.color)
    input = nil
    until valid_input?(input, player) && possible_move?(input, player)
      input = gets.chomp.split("", 3)
      input[1] = LETTER_TO_NUMBER.index(input[1].downcase) if input[1].match?(/[a-h]/)
      input[2] = input[2].to_i
      piece_to_move = possible_move(input, player)
      return [[piece_to_move], [input[1], input[2]]] if piece_to_move
    end
  end

  def valid_input?(input, player)
    return false if input.nil? || !input.is_a?(Array)

    return false unless input[0].match?(/[rnbqkpRNBQKP]/) && input[0].length == 1

    return false unless input[1].to_s.length == 1 && input[1].to_s.match?(/\d/)
    return false unless input[2].to_s.length == 1 && input[2].to_s.match?(/\d/)

    return false unless input[1][0].between?(0, 7) && input[2].between?(0, 7)

    # Check if input is reachable in one turn

    return false if @board[input[1]][input[2]] != "_" && @board[input[1]][input[2]].color == player.color

    true
  end

  def possible_move(input, player)
    # Get the array of moves using the PIECE_MOVES hash and input[0]
    # Loop through the array of pieces, checking if the piece can possibly reach that point
    # Only check pieces of the player's color.
    piece_name = LETTER_TO_PIECE[input[0]]
    moves = PIECE_MOVES[piece_name]
    target = [input[1], input[2]]

    @pieces.each do |piece|
      next if piece.color == player.color || piece.piece_name != piece_name

      x = piece.pos[0]
      y = piece.pos[1]

      moves.each do |move|
        return piece if x + move[0] == target[0] && y + move[1] == target[1]
      end
    end
    false
  end

  def game_over?
  end

  private

  def create_piece(color, piece_name, position)
    new_piece = Piece.new(color, piece_name, position)
    @pieces << new_piece
    new_piece
  end

  def set_board
    @board[0][0] = create_piece("white", "rook", [0, 0])
    @board[0][1] = create_piece("white", "knight", [0, 1])
    @board[0][2] = create_piece("white", "bishop", [0, 2])
    @board[0][3] = create_piece("white", "queen", [0, 3])
    @board[0][4] = create_piece("white", "king", [0, 4])
    @board[0][5] = create_piece("white", "bishop", [0, 5])
    @board[0][6] = create_piece("white", "knight", [0, 6])
    @board[0][7] = create_piece("white", "rook", [0, 7])

    @board[7][0] = create_piece("black", "rook", [7, 0])
    @board[7][1] = create_piece("black", "knight", [7, 1])
    @board[7][2] = create_piece("black", "bishop", [7, 2])
    @board[7][3] = create_piece("black", "queen", [7, 3])
    @board[7][4] = create_piece("black", "king", [7, 4])
    @board[7][5] = create_piece("black", "bishop", [7, 5])
    @board[7][6] = create_piece("black", "knight", [7, 6])
    @board[7][7] = create_piece("black", "rook", [7, 7])

    8.times do |i|
      @board[1][i] = create_piece("white", "pawn", [1, i])
      @board[6][i] = create_piece("black", "pawn", [6, i])
    end

    p @pieces
  end
end
