# To run these tests, simply execute `nimble test`.
import std/strutils
import unittest
import std/strformat
import hex
import std/sequtils
import std/sugar

test "export training data":
  let f = open("data.txt", fmWrite)
  defer: f.close()

  for game in 1..10:
    var hex = initHex()
    while true:
      var alpha: int = int.low
      var beta: int = int.high
      let (_, move) = hex.negamax(3, alpha, beta, hex.turn, (-1, -1))
      hex.grid[move[0], move[1]] = hex.turn

      let label = hex.grid.evaluate(Cell.Red)
      let gridString = hex.grid.toArray().map(x => $x).join("")
      f.writeLine($label & "-" & gridString)

      hex.turn = if hex.turn == Cell.Red: Cell.Blue else: Cell.Red
      if hex.grid.checkWin(Cell.Red):
        echo "🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴 Red won 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴"
        break
      if hex.grid.checkWin(Cell.Blue):
        echo "🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 Blue won 🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵"
        break
    hex.grid.print()

# test "player play":
#   var hex = initHex()
#   const abc = "ABCDEFGHIJK"
#   echo "Are you, the player, RED or BLUE? Or do you want the COMPUTER to play"
#   var playerColor = Cell.Blue
#   var response = readLine(stdin)
#   if response == "RED":
#     playerColor = Cell.Red
#   if response == "COMPUTER":
#     playerColor = Cell.Empty

#   while true:

#     if hex.turn == playerColor:
#       echo "YOUR MOVE? ex. F9"
#       var moveResponse = toSeq(readLine(stdin).items)
#       var x = parseInt(moveResponse.filter(x => x.isDigit()).join(""))
#       var moveLetter = moveResponse.filter(x => x.isAlphaAscii()).join("")
#       var y = abc.find(moveLetter)
#       hex.grid[x - 1, y] = hex.turn

#     else:
#       var alpha: int = int.low
#       var beta: int = int.high
#       let (_, move) = hex.negamax(3, alpha, beta, hex.turn, (-1, -1))
#       hex.grid[move[0], move[1]] = hex.turn
      
#     hex.grid.print()
#     echo &"Live 🔴 score {hex.grid.evaluate(Cell.Red)}"
#     echo &"Live 🔵 score {hex.grid.evaluate(Cell.Blue)}"

#     hex.turn = if hex.turn == Cell.Red: Cell.Blue else: Cell.Red
    
#     if hex.grid.checkWin(Cell.Red):
#       echo "🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴 Red won 🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴"
#       break
#     if hex.grid.checkWin(Cell.Blue):
#       echo "🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 Blue won 🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵"
#       break

#   check true