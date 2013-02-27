require 'set'

class WordTree
  attr_reader :children, :terminal

  def initialize(terminal = false)
    @children = {}
    @terminal = terminal
  end

  def child_at(letter)
    @children[letter]
  end

  def add_word(word)
    first_letter = word[0]
    child_terminal = (word.length == 1)

    @children[first_letter] ||= WordTree.new(child_terminal)

    @children[first_letter].add_word(word[1..-1]) unless child_terminal
  end
end

class PuzzleNode
  attr_accessor :neighbors, :visited
  attr_reader :value

  def initialize(value)
    @visited = false
    @value = value
    @neighbors = []
  end
end

class Puzzle
  attr_reader :nodes

  def initialize(rows)
    @nodes = []

    rows.map! do |row|
      row.map do |letter|
        PuzzleNode.new(letter)
      end
    end

    rows.each_with_index do |row, y|
      row.each_with_index do |node, x|
        [-1, 0, 1].product([-1, 0, 1]).each do |dx, dy|
          next if dx == 0 && dy == 0
          newx = x + dx
          newy = y + dy
          if newx >= 0 && newy >= 0 && rows[newy] && rows[newy][newx]
            node.neighbors << rows[newy][newx]
          end
        end
      end
    end

    @nodes = rows.flatten
  end
end

def puzzle_walk(puzzle, tree, words = Set.new, current_word = "", current_node = nil, visited = Set.new)
  return words unless tree

  nodes = if current_node
            current_node.neighbors
          else
            puzzle.nodes
          end

  if tree.terminal
    words << current_word
  end

  nodes.each do |node|
    next if visited.include?(node)
    words += puzzle_walk(puzzle, tree.child_at(node.value), words, current_word + node.value, node, visited + [current_node])
  end

  words
end


if File.exists?('marshal_tree')
  tree = Marshal.load(File.read('marshal_tree'))
else
  WORDS = File.read('dictionary.txt').split(/\r?\n/)
  tree = WordTree.new
  WORDS.each do |word|
    tree.add_word(word.upcase)
  end
  File.open('marshal_tree', 'w') do |f|
    f << Marshal.dump(tree)
  end
end

SCRABBLE_SCORES = {
  'A' => 1,
  'B' => 3,
  'C' => 3,
  'D' => 2,
  'E' => 1,
  'F' => 4,
  'G' => 2,
  'H' => 4,
  'I' => 1,
  'J' => 8,
  'K' => 5,
  'L' => 1,
  'M' => 3,
  'N' => 1,
  'O' => 1,
  'P' => 3,
  'Q' => 10,
  'R' => 1,
  'S' => 1,
  'T' => 1,
  'U' => 1,
  'V' => 4,
  'W' => 4,
  'X' => 8,
  'Y' => 4,
  'Z' => 10
}

class String
  def scrabble_score
    upcase.split('').map { |letter| SCRABBLE_SCORES[letter] }.reduce(:+)
  end
end

puzzle_rows = []

puts "Enter rows separated by newlines, with no spaces: "
4.times do
  puzzle_rows << gets.upcase.split('')
end

puzzle = Puzzle.new(puzzle_rows)

puts puzzle_walk(puzzle, tree).sort_by(&:scrabble_score)
