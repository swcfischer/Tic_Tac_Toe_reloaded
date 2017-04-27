INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]
WHO_STARTS = 'choose'
def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/MethodLength, Metrics/AbcSize

def display_board(brd, score)
  system 'clear'
  puts "You are 'X', Computer is 'O' "
  puts "Your score: #{score[:player]}. Computer score: #{score[:computer]}."
  puts ''
  puts "     |     |     "
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}  "
  puts "     |     |     "
  puts "-----+-----+-----"
  puts "     |     |     "
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}  "
  puts "     |     |     "
  puts ''
end

# rubocop:enable Metrics/MethodLength, Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each do |k|
    new_board[k] = INITIAL_MARKER
  end
  new_board
end

def empty_squares(brd)
  brd.keys.select { |k| brd[k] == INITIAL_MARKER }
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt("Choose a square #{joinor(empty_squares(brd))}")
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt("You must choose a valid choice!")
  end
  brd[square] = PLAYER_MARKER
end

def computer_places_piece!(brd)
  if brd[5] == INITIAL_MARKER
    computer_take_5(brd)
  elsif computer_threat(brd, COMPUTER_MARKER)
    computer_offense(brd)
  elsif computer_threat(brd, PLAYER_MARKER) && !computer_threat(brd, COMPUTER_MARKER)
    computer_defense(brd)
  elsif !computer_threat(brd, COMPUTER_MARKER) && !computer_threat(brd, PLAYER_MARKER)
    square = empty_squares(brd).sample
    brd[square] = COMPUTER_MARKER
  end
end

def computer_take_5(brd)
  if brd[5] == INITIAL_MARKER
    brd[5] = COMPUTER_MARKER
  end
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player wins!'
    elsif brd.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer wins!'
    end
  end
  nil
end

def joinor(arr, delimiter=', ', word='or')
  case arr.count
  when 1
    arr
  when 2
    "#{arr[0]} #{word} #{arr[1]}"
  when 3..9
    arr[-1] = "#{word} #{arr.last} "
    arr.join(delimiter)
  end
end

def update_score(brd, score)
  if detect_winner(brd) == 'Player wins!'
    score[:player] += 1
  elsif detect_winner(brd) == 'Computer wins!'
    score[:computer] += 1
  end
  puts "Player score is #{score[:player]}. Computer score is #{score[:computer]}."
end

def computer_threat(brd, sign)
  WINNING_LINES.each do |line|
    if brd.values_at(line[0], line[1], line[2]).count(sign) == 2
      if brd.values_at(line[0], line[1], line[2]).count(INITIAL_MARKER) == 1
        return true
      end
    end
  end
  nil
end

def computer_defense(brd)
  WINNING_LINES.each do |line|
    if brd.values_at(line[0], line[1], line[2]).count(PLAYER_MARKER) == 2
      line.each do |num|
        if brd[num] == " " &&
           ((brd.values.count(PLAYER_MARKER) == brd.values.count(COMPUTER_MARKER) + 1) ||
           (brd.values.count(PLAYER_MARKER) == brd.values.count(COMPUTER_MARKER) - 1) ||
           (brd.values.count(PLAYER_MARKER) == brd.values.count(COMPUTER_MARKER)))
          brd[num] = COMPUTER_MARKER
        end
      end
    end
  end
end

def count_check(brd, line, sign, times)
  brd.values_at(*line).count(sign) == times
end

def computer_offense(brd)
  WINNING_LINES.each do |line|
    if count_check(brd, line, COMPUTER_MARKER, 2) &&
       count_check(brd, line, INITIAL_MARKER, 1)
      line.each do |num|
        if brd[num] == " "
          brd[num] = COMPUTER_MARKER
        end
      end
    end
  end
end

def place_piece!(brd, players, score)
  if players['Player'] == 'X'
    player_places_piece!(brd)
    computer_places_piece!(brd) unless someone_won?(brd) || board_full?(brd)
  elsif players['Computer'] == 'X'
    computer_places_piece!(brd)
    display_board(brd, score)
    player_places_piece!(brd) unless someone_won?(brd) || board_full?(brd)
  end
end

def ask_who_first(players)
  if WHO_STARTS == 'choose'
    prompt("Who would you like to go first?")
    prompt("p (for player) c (for computer)")
  end
  loop do
    choice = gets.chomp.downcase
    if choice.start_with?('c')
      players['Computer'] = 'X'
      break
    elsif choice.start_with?('p')
      players['Player'] = 'X'
      break
    else
      prompt("Must provide valid input!")
      prompt("p (for player) c (for computer)")
    end
  end
end

players = { 'Player' => ' ', 'Computer' => ' ' }
score = {}
loop do
  score = { player: 0, computer: 0 }
  loop do
    board = initialize_board

    loop do
      display_board(board, score)
      ask_who_first(players) if !players.values.include?('X')
      place_piece!(board, players, score)
      break if someone_won?(board) || board_full?(board)
    end

    update_score(board, score)
    display_board(board, score)
    if someone_won?(board)
      prompt(detect_winner(board))
    else
      prompt("It's a tie!")
    end

    break if score[:player] >= 5 || score[:computer] >= 5
  end

  prompt("Do you want to play again?")
  prompt("(y or n)")
  choice = gets.chomp
  break unless choice.downcase.start_with?('y')
end
prompt("Thank you for playing! Goodbye!")
