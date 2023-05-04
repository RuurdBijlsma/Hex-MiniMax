import nimpy
from std/random import sample, randomize, rand
import std/strutils
import std/strformat

type Cell* = enum
  Empty, Red, Blue
const Width = 5
const Height = 5
type Grid* = ref array[Width, array[Height, Cell]]

type Node* = ref object
    terminal: bool
    children: seq[Node]

proc `[]`*(g: Grid, x, y: int): Cell =
  return g[x][y]
proc `[]=`*(g: Grid, x, y: int, val: Cell) = 
  g[x][y] = val

type Hex* = ref object of PyNimObjectExperimental 
  grid*: Grid
  ended*: bool
  turn*: Cell
  doEcho*: bool

proc restart(self: Hex) =
    for x in 0..<Width:
        for y in 0..<Height:
            self.grid[x, y] = Cell.Empty

proc initHex*(): Hex {.exportpy.} =
  randomize()
  let hex = Hex(turn: Cell.Red)
  hex.grid = new(Grid)
  hex.restart()
  return hex

const neighbours = [
    (1, 0),#right
    (-1, 0),#left

    (0, 1),#bot right
    (-1, 1),#bot left

    (0, -1),#top right
    (1, -1),#top left
]

proc checkWin*(grid: Grid, turn: Cell): bool =
    var visited: array[Width * Height, bool]
    var queue = newSeq[(int, int)]()
    if turn == Cell.Red:
        for x in 0..<Width:
            if grid[x, 0] == Cell.Red:
                queue.add((x, 0))
                visited[x] = true
    else:
        for y in 0..<Height:
            if grid[0, y] == Cell.Blue:
                queue.add((0, y))
                visited[y * Width] = true
    while queue.len > 0:
        var (x, y) = queue[queue.high]
        queue.delete(queue.high)

        for (xp, yp) in neighbours:
            var xn = x + xp
            var yn = y + yp
            if xn < 0 or xn >= Width or yn < 0 or yn >= Height or grid[xn, yn] != turn or visited[yn * Width + xn]:
                continue
            if turn == Cell.Red and yn == Height - 1:
                return true
            if turn == Cell.Blue and xn == Width - 1:
                return true
            visited[yn * Width + xn] = true
            queue.add((xn, yn))

    return false

proc print*(grid: Grid) {.exportpy.} =
  echo "====================================="
  for y in 0..<Height:
    for x in 0..<Width:
      let val = grid[x, y]
    #   stdout.write(&"{x} ")
      if val == Cell.Empty:
        stdout.write("⚫ ")
      if val == Cell.Blue:
        stdout.write("🔵 ")
      if val == Cell.Red:
        stdout.write("🔴 ")
    stdout.write("\n" & " ".repeat(y + 1))
  stdout.write("\n")
  flushFile(stdout)

proc evaluate*(grid: Grid, turn: Cell): int =
    let iterations = 200
    var wins = 0
    for i in 0..<iterations:
        var copy = grid[]
        # Fill empty cells randomly
        for x in 0..<Width:
            for y in 0..<Height:
                if grid[x, y] == Cell.Empty:
                    grid[x, y] = Cell(rand(1..2))
        if grid.checkWin(turn):
            # echo &"Turn {turn} won!"
            wins += 1
        # grid.print()
        grid[] = copy
    return -(iterations div 2) + wins

proc getPossibleMoves(self: Hex): seq[(int,int)] =
    var possibleMoves = newSeq[(int,int)]()

    for x in 0..<Width:
        for y in 0..<Height:
            if self.grid[x, y] == Cell.Empty:
                possibleMoves.add((x, y))
    return possibleMoves

proc alphaBeta*(self: Hex, depth: int, alpha: var int, beta: var int, turn: Cell, lastMove: (int, int)): (int, (int, int)) =
    let otherTurn = if turn == Cell.Red: Cell.Blue else: Cell.Red
    if depth == 0 or self.grid.checkWin(otherTurn):
        let value = self.grid.evaluate(self.turn)
        if self.doEcho:
            echo &"TERMINAL move: {lastMove} has value: {value}"
        return (value, lastMove)
    let maximizing = self.turn == turn
    let possibleMoves = self.getPossibleMoves()
    # echo &"max: {maximizing}, depth: {depth}, turn: {turn}, possiblemoves: {possibleMoves}"
    if maximizing:
        var bestValue = int.low
        var bestMove: (int, int)
        for (x, y) in possibleMoves:
            self.grid[x, y] = turn
            let (value, move) = self.alphaBeta(depth - 1, alpha, beta, otherTurn, (x, y))
            self.grid[x, y] = Cell.Empty
            if value > bestValue:
                bestValue = value
                bestMove = move
            # if value > beta:
            #     break # Beta cutoff
            alpha = max(alpha, value)
        return (bestValue, bestMove)
    else:
        var bestValue = int.high
        var bestMove: (int, int)
        for (x, y) in possibleMoves:
            self.grid[x, y] = turn
            let (value, move) = self.alphaBeta(depth - 1, alpha, beta, otherTurn, (x, y))
            self.grid[x, y] = Cell.Empty
            if value < bestValue:
                bestValue = value
                bestMove = move
            # if value < alpha:
            #     break # Alpha cutoff
            beta = min(beta, value)
        return (bestValue, bestMove)

proc doMove*(self: Hex) =
    let possibleMoves = self.getPossibleMoves()
    
    var bestScore = -1
    var bestMove = (0, 0)

    for (x, y) in possibleMoves:
        self.grid[x, y] = self.turn
        var score = self.grid.evaluate(self.turn)
        # echo &"score {score}"
        self.grid[x, y] = Cell.Empty
        if score > bestScore:
            bestScore = score
            bestMove = (x, y)
    
    self.grid[bestMove[0], bestMove[1]] = self.turn

    if self.turn == Cell.Red:
        self.turn = Cell.Blue
    else: self.turn = Cell.Red