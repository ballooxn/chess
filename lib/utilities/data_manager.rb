module DataManager
  def save_game(board, player1, player2, pieces, num_moves)
    data = {
      board: board,
      player1: player1,
      player2: player2,
      pieces: pieces,
      num_moves: num_moves
    }
    Dir.mkdir("saves") unless Dir.exist?("saves")
    File.write("saves/save.txt", Marshal.dump(data))
  end

  def load_data
    return unless File.exist?("saves/save.txt")

    Marshal.load(File.read("saves/save.txt"))
  end
end
