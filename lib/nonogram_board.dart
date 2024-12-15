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
        if (playerState[i][j] != widget.solution[i][j]) {
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
              Navigator.pop(context); // Navigate back to the puzzle menu
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
                  // Column Clues
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: gridSize * 0.8), // Slightly reduce the offset
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
                  // Row Clues and Grid
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
                      // Grid
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
                                reset: resetBoard, // Pass reset trigger
                              );
                            }),
                          );
                        }),
                      ),
                    ],
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

  const NonogramTile({
    super.key,
    required this.isSolution,
    required this.gridSize,
    required this.onTileTapped,
    required this.reset,
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
        _tileState = TileState.unmarked; // Reset tile state
      });
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
            _tileState = TileState.filled; // White → Blue
          } else if (_tileState == TileState.filled) {
            _tileState = TileState.markedEmpty; // Blue → Grey
          } else {
            _tileState = TileState.unmarked; // Grey → White
          }
        });

        widget.onTileTapped(_tileState == TileState.filled ? 1 : 0);
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
