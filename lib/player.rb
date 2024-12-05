require_relative "utilities/display"
require_relative "../lib/referee"

class Player
  include Display
  attr_accessor :color, :rounds_won

  LETTER_TO_NUMBER = %w[a b c d e f g h].freeze
  LETTER_TO_PIECE = { "p" => "pawn", "n" => "knight", "k" => "king", "b" => "bishop", "q" => "queen",
                      "r" => "rook" }.freeze

  def initialize(color, rounds_won = 0)
    @color = color
    @rounds_won = rounds_won
  end

  def player_input(referee, board)
    # The first part of input is the piece, second and third is position to move to.
    Display.player_input(@color)
    valid_move = false
    until valid_move
      input = gets.chomp.downcase
      if %w[oo ooo].include?(input) # we're castling
        input = Castle.castle(@color, input, board, referee)
        next if input == false

        return input
      elsif input == "save"
        return "save"
      end

      input = input_to_array(input)

      next unless referee.valid_input?(input, @color)

      input[0] = LETTER_TO_PIECE[input[0]]

      piece_to_move = referee.piece_to_move(input, @color)
      return [piece_to_move, [input[1], input[2]]] if piece_to_move
    end
  end

  def input_to_array(input)
    case input.length
    when 4
      input = input.split("", 4)
      input.push(input[1])
      input.delete_at(1) # Move the column/row index of piece to the back.
      input[3].to_i if input[3].match?(/\d/)
    when 3
      input = input.split("", 3)
    when 2
      # Putting only the target without a piece means you're moving a pawn.
      input = input.split("", 2)
      input.unshift("p")
    else
      return nil
    end

    # reverse the numbers as the letters should be the y input
    original_input2 = input[2]
    input[2] = LETTER_TO_NUMBER.index(input[1].downcase) if input[1].match?(/[a-h]/)
    input[1] = original_input2.to_i
    input
  end
end
