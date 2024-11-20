class Piece
  attr_accessor :times_moved
  attr_reader :color, :piece

  def initialize(color, piece, times_moved = 0)
    @color = color
    @piece = piece
    @times_moved = times_moved
  end
end
