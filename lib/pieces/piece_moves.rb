module PossibleMoves
  # Make sure to check if its the pawn's first move, if it isnt then dont let pawn try the 1st move.
  # For the second and third moves, check if there is an opposite color piece to the left-diaagonal and right-diagonal
  WHITE_PAWN_MOVES = [[2, 0], [1, 1], [1, -1], [1, 0]].freeze
  BLACK_PAWN_MOVES = [[-2, 0], [-1, 1], [-1, -1], [-1, 0]].freeze

  KNIGHT_MOVES = [[1, -2], [2, -1], [2, 1], [1, 2], [-1, 2], [-2, 1], [-1, -2], [-2, -1]].freeze
  BISHOP_MOVES = [[1, 1], [2, 2], [3, 3], [4, 4], [5, 5], [6, 6], [7, 7],
                  [-1, -1], [-2, -2], [-3, -3], [-4, -4], [-5, -5], [-6, -6], [-7, -7],
                  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7],
                  [-1, 1], [-2, 2], [-3, 3], [-4, 4], [-5, 5], [-6, 6], [-7, 7]].freeze
  ROOK_MOVES = [[-1, 0], [-2, 0], [-3, 0], [-4, 0], [-5, 0], [-6, 0], [-7, 0],
                [1, 0], [2, 0], [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
                [0, -1], [0, -2], [0, -3], [0, -4], [0, -5], [0, -6], [0, -7],
                [0, 1], [0, 2], [0, 3], [0, 4], [0, 5], [0, 6], [0, 7]].freeze
  QUEEN_MOVES = ROOK_MOVES + BISHOP_MOVES
  # check if king is in check after move
  KING_MOVES = [[1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1], [0, -1], [1, -1]].freeze
end
