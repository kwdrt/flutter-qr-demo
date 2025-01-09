import 'package:flutter/material.dart';

class NonogramBoard extends StatefulWidget {
  final String title;
  final List<List<int>> solution;
  final List<List<int>> rowClues;
  final List<List<int>> columnClues;

  const NonogramBoard({
    super.key,
    required this.title,
    required this.solution,
    required this.rowClues,
    required this.columnClues,
  });

  @override
  State<NonogramBoard> createState() => _NonogramBoardState();
}

class _NonogramBoardState extends State<NonogramBoard> {
  late final int rows;
  late final int cols;

  // Player's current board state
  late List<List<int>> playerState;

  bool resetBoard = false;

  @override
  void initState() {
    super.initState();
    rows = widget.solution.length;
    cols = widget.solution[0].length;
    playerState = List.generate(rows, (_) => List.generate(cols, (_) => 0));
  }

  void checkSolution() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (widget.solution[i][j] == 1 && playerState[i][j] != 1) {
          return;
        }
        if (widget.solution[i][j] == 0 && playerState[i][j] == 1) {
          return;
        }
      }
    }

    // If no mismatches, the solution is correct
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Congratulations!"),
        content: Text(
            "You have completed the puzzle correctly. Would you like to solve it again?"),
        actions: [
          TextButton(
            onPressed: () {
              // Reset the board
              setState(() {
                playerState =
                    List.generate(rows, (_) => List.generate(cols, (_) => 0));
                resetBoard = !resetBoard;
              });
              Navigator.of(context).pop();
            },
            child: Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("No"),
          ),
        ],
      ),
    );
  }

  void giveHint() {
    List<List<int>> hintMarkedPositions = [];
    List<List<int>> hintBlankPositions = [];

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        if (playerState[i][j] != 1 && widget.solution[i][j] == 1) {
          hintMarkedPositions.add([i, j]);
        } else if (playerState[i][j] == 1 && widget.solution[i][j] == 0) {
          hintBlankPositions.add([i, j]);
        }
      }
    }

    setState(() {
      if (hintMarkedPositions.isNotEmpty) {
        final randomHint = (hintMarkedPositions..shuffle()).first;
        playerState[randomHint[0]][randomHint[1]] = 1;
      } else if (hintBlankPositions.isNotEmpty) {
        final randomHint = (hintBlankPositions..shuffle()).first;
        playerState[randomHint[0]][randomHint[1]] = 0;
      }
      checkSolution();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Dynamically calculate grid and font size based on screen width
    final gridSize = screenWidth / (cols + 4);
    final fontSize = gridSize * 0.3;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: gridSize * 0.8),
                      ...List.generate(cols, (col) {
                        return Container(
                          width: gridSize,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: widget.columnClues[col]
                                .map((clue) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0),
                                      child: Text(
                                        '$clue',
                                        style: TextStyle(
                                            fontSize: fontSize, height: 1.0),
                                      ),
                                    ))
                                .toList(),
                          ),
                        );
                      }),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(rows, (row) {
                          return Container(
                            height: gridSize,
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: widget.rowClues[row]
                                  .map((clue) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 2.0),
                                        child: Text('$clue',
                                            style: TextStyle(
                                                fontSize: fontSize, height: 1.0)),
                                      ))
                                  .toList(),
                            ),
                          );
                        }),
                      ),
                      Column(
                        children: List.generate(rows, (row) {
                          return Row(
                            children: List.generate(cols, (col) {
                              return NonogramTile(
                                isSolution: widget.solution[row][col] == 1,
                                gridSize: gridSize,
                                onTileTapped: (value) {
                                  setState(() {
                                    playerState[row][col] = value;
                                    checkSolution();
                                  });
                                },
                                reset: resetBoard,
                                playerState: playerState,
                                row: row,
                                col: col,
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: giveHint,
                    child: Text("Give Hint"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum TileState { unmarked, filled, markedEmpty }

class NonogramTile extends StatefulWidget {
  final bool isSolution;
  final double gridSize;
  final ValueChanged<int> onTileTapped;
  final bool reset;
  final List<List<int>> playerState;
  final int row;
  final int col;

  const NonogramTile({
    super.key,
    required this.isSolution,
    required this.gridSize,
    required this.onTileTapped,
    required this.reset,
    required this.playerState,
    required this.row,
    required this.col,
  });

  @override
  State<NonogramTile> createState() => _NonogramTileState();
}

class _NonogramTileState extends State<NonogramTile> {
  TileState _tileState = TileState.unmarked;

  @override
  void didUpdateWidget(NonogramTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reset != widget.reset) {
      setState(() {
        _tileState = TileState.unmarked;
      });
    }
    if (widget.playerState[widget.row][widget.col] == 1) {
      _tileState = TileState.filled;
    } else if (widget.playerState[widget.row][widget.col] == 0) {
      _tileState = TileState.unmarked;
    } else if (widget.playerState[widget.row][widget.col] == -1) {
      _tileState = TileState.markedEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color tileColor;
    switch (_tileState) {
      case TileState.filled:
        tileColor = Colors.orange;
        break;
      case TileState.markedEmpty:
        tileColor = Colors.grey;
        break;
      default:
        tileColor = Colors.white;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_tileState == TileState.unmarked) {
            _tileState = TileState.filled;
            widget.playerState[widget.row][widget.col] = 1;
          } else if (_tileState == TileState.filled) {
            _tileState = TileState.markedEmpty;
            widget.playerState[widget.row][widget.col] = -1;
          } else {
            _tileState = TileState.unmarked;
            widget.playerState[widget.row][widget.col] = 0;
          }
        });

        widget.onTileTapped(widget.playerState[widget.row][widget.col]);
      },
      child: Container(
        width: widget.gridSize,
        height: widget.gridSize,
        decoration: BoxDecoration(
          color: tileColor,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}
