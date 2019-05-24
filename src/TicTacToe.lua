empty = ' '
white = 'X'
black = 'O'

levelBeg  = 'B'
levelExp  = 'E'

inst_main  = 'M'   -- main instance
inst_clone = 'C'   -- clone for minmax algorithm

TicTacToe = { }    -- class

function TicTacToe:new(g)
  board = {
    fields       = { {}, {}, {} },
    token        = g and g.token or 0,
    winner       = g and g.winner or empty,
    activePlayer = g and g.activePlayer or empty,
    level        = g and g.level or levelExp,
    inst_type    = g and inst_clone or inst_main
  }
  setmetatable(board, self)
  self.__index = self
  for i = 1, 3, 1 do
    for j = 1, 3, 1 do
      board.fields[i][j] = g and g.fields[i][j] or empty
    end
  end
  return board
end

function TicTacToe:switchColor(c)
  local ret = emtpy
  if c == white then
    ret = black
  elseif c == black then
    ret = white
  end
  return ret
end

function TicTacToe:hasThreeInARow(c)
  if ( self.fields[1][1] == c and self.fields[2][2] == c and self.fields[3][3] == c ) or
    ( self.fields[3][1] == c and self.fields[2][2] == c and self.fields[1][3] == c ) then
    return true
  end
  for i = 1, 3 do
    if ( self.fields[i][1] == c and self.fields[i][2] == c and self.fields[i][3] == c ) or
      ( self.fields[1][i] == c and self.fields[2][i] == c and self.fields[3][i] == c ) then
      return true
    end
  end
  return false
end

function TicTacToe:gameIsOver()
  if self.winner ~= empty or self.token == 9 then
    return true
  end
  return false
end

function TicTacToe:readLevel()
  io.write('Enter Level (0 == Beginner, 1 == Expert):')
  local i = io.read("*number")
  if i == 0 then
    self.level = levelBeg
  end
end

function TicTacToe:move(i, j, color)
  if self:gameIsOver() then return end

  if self.fields[i][j] == empty then
    self.fields[i][j] = color
    self.token = self.token + 1
    self:checkWin(color)
    return true
  end
  return false
end

function TicTacToe:undoMove(i, j)
  self.fields[i][j] = empty
  self.token = self.token - 1
  self.winner = empty
end

function TicTacToe:readMove(color)
  if self:gameIsOver() then return end
  
  io.write('Enter row and column (or 0 for comupter move):')
  local valid = false
  while valid == false do
    local i = io.read("*number")
    if i == 0 then
      self:computerMove(color)
      valid = true
    else
      local j = io.read("*number")
      valid = self:move(i, j, color)
    end
  end
end

function TicTacToe:randomMove(color)
  if self:gameIsOver() then return end

  math.randomseed( os.time() )
  local i = math.random(3)
  local j = math.random(3)
  local zi = 0
  local zj = 0
  local i_org = i
  while self.fields[i][j] ~= empty do
    if zi < 2 then
      i = i + 1
      if i == 4 then i = 1 end
      zi = zi + 1
    elseif zj < 2 then
      zi = 0
      i = i_org
      j =  j + 1
      if j == 4 then j = 1 end
      zj = zj + 1
    end
  end
  self.fields[i][j] = color
  self.token = self.token + 1
  self:checkWin(color)
end

function TicTacToe:minmaxMove(color)
  if self:gameIsOver() then return self:score() end

  local bestScore = ( self.activePlayer == color ) and -9999 or 9999
  local bestI
  local bestJ

  for i=1, 3, 1 do
    for j=1, 3, 1 do
      if self.fields[i][j] == empty then
        self:move(i, j, color)
        local m = TicTacToe:new(self)
        local color2 = self:switchColor(color)
        local tempScore = m:minmaxMove(color2)
        if ( color == self.activePlayer and tempScore >= bestScore ) or ( color ~= self.activePlayer and tempScore <= bestScore ) then
          bestScore = tempScore
          bestI = i
          bestJ = j
        end
        self:undoMove(i, j)
      end
    end
  end
  if self.inst_type == inst_main then
    self:move(bestI, bestJ, color)
  end
  return bestScore
end

function TicTacToe:computerMove(color)
  self.activePlayer = color
  if self.level == levelExp then
    self:minmaxMove(color)
   else
    self:randomMove(color)
  end
  self.activePlayer = empty
end

function TicTacToe:score()
  if self.winner == empty then
    return 0;
  elseif self.winner == self.activePlayer then
    return 1
  else
    return -1
  end
end

function TicTacToe:checkWin(color)
  if self:hasThreeInARow(color) then
    self.winner = color
  end
end

function TicTacToe:printBoard()
  io.write('+---+---+---+\n')
  for i = 1, 3, 1 do
    io.write('|')
    for j = 1, 3, 1 do
      io.write(' ' .. self.fields[i][j] .. ' ')
      io.write('|')
    end
    io.write('\n+---+---+---+\n')
  end
  self:printResult()
end

function TicTacToe:printResult()
  if self.winner ~= empty then
    print('The winner is ' .. self.winner )
  elseif self.token == 9 then
    print('The game ended with a draw' )
  end
end

function main()
  local game = TicTacToe:new()
  game:readLevel()
  while game:gameIsOver() == false do
    game:readMove(white)
    game:printBoard()
    game:computerMove(black)
    game:printBoard()
  end
end

main()
