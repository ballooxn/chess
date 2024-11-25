class Piece
  attr_accessor :times_moved, :pos
  attr_reader :color, :piece_name

  def initialize(color, piece_name, pos, times_moved = 0)
    @color = color
    @piece_name = piece_name
    @pos = pos
    @times_moved = times_moved
  end
end
