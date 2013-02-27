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


puzzle_rows = []

puts "Enter rows separated by newlines, with no spaces: "
4.times do
  puzzle_rows << gets.upcase.split('')
end

puzzle = Puzzle.new(puzzle_rows)

puts puzzle_walk(puzzle, tree).to_a.sort_by(&:length)
