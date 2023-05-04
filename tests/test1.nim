# To run these tests, simply execute `nimble test`.
import std/monotimes
from std/times import inMilliseconds
import unittest
import std/strformat
import hex

test "basic play":
  var hex = initHex()
  let startTime = getMonoTime()

  for i in 0..1:
    hex.doMove()
    if hex.grid.checkWin(Cell.Red):
      echo "Red won"
      break
    if hex.grid.checkWin(Cell.Blue):
      echo "Blue won"
      break

  let duration = (getMonoTime() - startTime).inMilliseconds
  hex.grid.print()
  echo &"duration: {duration}"
  check true

test "minimax":
  var hex = initHex()

  while true:

    let (score, move) = hex.minimax(3, hex.turn, (-1, -1))
    hex.grid[move[0], move[1]] = hex.turn
    hex.grid.print()
    echo &"Score {score}"
    echo &"Live score {hex.grid.evaluate(Cell.Red)}"

    hex.turn = if hex.turn == Cell.Red: Cell.Blue else: Cell.Red
    
    if hex.grid.checkWin(Cell.Red):
      echo "Red won"
      break
    if hex.grid.checkWin(Cell.Blue):
      echo "Blue won"
      break

  check true