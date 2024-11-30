class Piece
  attr_accessor :times_moved, :pos
  attr_reader :color, :piece_name

  @@pieces = []

  def initialize(color, piece_name, pos, times_moved = 0)
    @color = color
    @piece_name = piece_name
    @pos = pos
    @times_moved = times_moved

    @@pieces << self
  end

  def self.pieces
    @@pieces
  end

  def self.find_matching_pieces(piece_name, color, column = nil, row = nil)
    array = []

    Piece.pieces.each do |p|
      next unless p.piece_name == piece_name && p.color == color

      if column
        next unless p.pos[1] == column
      elsif row
        next unles p.pos[0] == row
      end

      array << p
    end
    array
  end

  def self.find_king(color)
    Piece.pieces.find { |p| p.piece_name == "king" && p.color == color }
  end
end
