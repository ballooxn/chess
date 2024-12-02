require_relative "../lib/game"

describe Game do
  describe "#game_loop" do
  end
end

describe Referee do
  describe "#stalemate?" do
    white_king = Piece.new("white", "king", [7, 0])
    black_queen = Piece.new("black", "queen", [5, 1])
    black_king = Piece.new("black", "king", [5, 3])

    it "returns true for a stalemate position" do
      stalemate_board = [
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        ["_", black_queen, black_king, "_", "_", "_", "_", "_"],
        %w[_ _ _ _ _ _ _ _],
        [white_king, "_", "_", "_", "_", "_", "_", "_"] # White king

      ]

      referee = Referee.new(stalemate_board)
      expect(referee.stalemate?(white_king)).to be true
    end

    it "returns false for a non-stalemate position" do
      # Create a board with a non-stalemate position
      # (e.g. king and rook vs king, with a possible move)
      white_rook = Piece.new("white", "rook", [7, 3])

      non_stalemate_board = [
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        %w[_ _ _ _ _ _ _ _],
        ["_", black_queen, black_king, "_", "_", "_", "_", "_"],
        %w[_ _ _ _ _ _ _ _],
        [white_king, "_", "_", white_rook, "_", "_", "_", "_"] # White king and rook
      ]
      non_stalemate_referee = Referee.new(non_stalemate_board)
      expect(non_stalemate_referee.stalemate?(white_king)).to be false
    end
  end
end
