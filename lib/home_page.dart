import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_test/AppState.dart';
import 'nonogram_board.dart';
import 'puzzles.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var qrCode, size, colors, truthArrays;
    var parsedRowClues, parsedColClues;
    var valid = false;

    if (appState.qrCodes.isNotEmpty) {
      qrCode = appState.qrCodes.last;
    }

    if (qrCode != null) {
      (valid, size, colors, truthArrays) = getPuzzleData(qrCode);
      if (valid) {
        parsedRowClues = getRowClues(truthArrays[0]);
        parsedColClues = getColumnClues(truthArrays[0]);
      }
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Puzzle Menu',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NonogramBoard(
                      title: 'Puzzle 1',
                      solution: puzzle1Solution,
                      rowClues: puzzle1RowClues,
                      columnClues: puzzle1ColumnClues,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Puzzle 1',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NonogramBoard(
                      title: 'Puzzle 2',
                      solution: puzzle2Solution,
                      rowClues: puzzle2RowClues,
                      columnClues: puzzle2ColumnClues,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Puzzle 2',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Add more buttons for additional puzzles
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: valid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NonogramBoard(
                            title: 'QR Puzzle',
                            solution: truthArrays[0],
                            rowClues: parsedRowClues,
                            columnClues: parsedColClues,
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Puzzle QR',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// structure of a correct puzzle
// <size> <color> (times 1-n) <up to 16x16 size string of positions 0-1> (times 1-n)
// example - 4 #00FF00 0110111111110110
// return - valid, size, colors, truthArrays (one for each color)

(bool, int, List<String>, List<List<List<int>>>) getPuzzleData(String qrCode) {
  // print(qrCode);
  if (qrCode != "noCode") {
    // print("Got here");
    var dataParts = qrCode.split(" ");
    // print("split to " + dataParts.toString());
    final size = int.parse(dataParts[0]);
    // print(size);
    // print(dataParts.length);
    //integer division is ~/
    final colorCount = (dataParts.length - 1) ~/ 2;
    // print(colorCount);
    List<String> colors = [];
    for (var i = 0; i < colorCount; i++) {
      colors.add(dataParts[i + 1]);
    }
    // print(colors);
    var truthArrayStrings = [];
    for (var i = 0; i < colorCount; i++) {
      truthArrayStrings.add(dataParts[i + colorCount + 1]);
    }
    // print(truthArrayStrings);
    //array of 2d arrays :/
    List<List<List<int>>> truthArrays = [];
    //2D array init :/
    //should be done once for each color - current implementation only checks for one now
    //one 2D array for every color
    for (var arrayNum = 0; arrayNum < colorCount; arrayNum++) {
      List<List<int>> tmpArray = [];
      for (var i = 0; i < size; i++) {
        List<int> tmpRow = [];
        for (var j = 0; j < size; j++) {
          tmpRow.add(int.parse(truthArrayStrings[arrayNum][i * size + j]));
        }
        tmpArray.add(tmpRow);
      }
      truthArrays.add(tmpArray);
    }
    return (true, size, colors, truthArrays);
  }
  return (false, 0, [], []);
}

List<List<int>> getRowClues(List<List<int>> solution) {
  List<List<int>> results = [];

  for (final row in solution) {
    List<int> rowClues = [];
    int currentChain = 0;

    for (final cell in row) {
      if (cell == 1) {
        currentChain++;
      } else {
        if (currentChain > 0) {
          rowClues.add(currentChain);
          currentChain = 0;
        }
      }
    }

    // Add the last chain if it's not empty
    if (currentChain > 0) {
      rowClues.add(currentChain);
    }

    results.add(rowClues);
  }
  print(results);
  return results;
}

List<List<int>> getColumnClues(List<List<int>> solution) {
  final numRows = solution.length;
  final numCols = solution[0].length;
  List<List<int>> results = [];

  for (int colIndex = 0; colIndex < numCols; colIndex++) {
    List<int> colClues = [];
    int currentChain = 0;

    for (int rowIndex = 0; rowIndex < numRows; rowIndex++) {
      final cellValue = solution[rowIndex][colIndex];
      if (cellValue == 1) {
        currentChain++;
      } else {
        if (currentChain > 0) {
          colClues.add(currentChain);
          currentChain = 0;
        }
      }
    }

    // Add the last chain if it's not empty
    if (currentChain > 0) {
      colClues.add(currentChain);
    }

    results.add(colClues);
  }

  return results;
}
