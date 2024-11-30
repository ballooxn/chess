module Display
  PIECE_TO_NOTATION = { "white" => { "pawn" => "\u265F", "knight" => "\u265E", "bishop" => "\u265D",
                                     "king" => "\u265A", "queen" => "\u265B", "rook" => "\u265C" },
                        "black" => { "pawn" => "\u2659", "knight" => "\u2658", "bishop" => "\u2657",
                                     "king" => "\u2654", "queen" => "\u2655", "rook" => "\u2656" } }.freeze
  def self.intro
    puts "Welcome to Chess!"
  end

  def self.player_input(color)
    puts "#{color.capitalize} player, pick which piece to move and where to move it!"
    puts "Type it in chess notation, (ex: nf5) to move the knight to F5"
    puts "You can just type the target for pawns (ex: d2) or type the column/row of the piece to move (ex: nbd2)"
  end

  def self.display_board(board)
    puts ""
    board.each_with_index do |row, row_index|
      print "#{row_index}: "
      row.each_with_index do |piece, col_index|
        if piece == "_"
          print col_index == 7 ? "| _ |" : "| _ "
          next
        end
        notation = PIECE_TO_NOTATION[piece.color][piece.piece_name]
        print col_index == 7 ? "| #{notation} |" : "| #{notation} "
      end
      puts ""
    end
    print "     a   b   c   d   e   f   g   h"
    puts ""
  end

  def self.checkmate(winner, num_moves)
    puts "Checkmate! #{winner.capitalize} wins after #{num_moves} moves!"
  end
end
