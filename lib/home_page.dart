import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:qr_test/QrCodeGenerator.dart';
import 'dart:convert';
import 'nonogram_board.dart';
import 'package:qr_test/AppState.dart';
import 'puzzles.dart';
import 'create_puzzle.dart';

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
            const Text(
              'Nonograms',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Creative Logic Puzzles',
              style: TextStyle(
                fontSize: 24.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SolvePuzzlesScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Solve Puzzles',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePuzzleScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Create Puzzle',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: valid
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NonogramBoard(
                            title: 'Puzzle QR',
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
            const SizedBox(height: 20),
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

String generateQRCode(List<List<int>> solution) {
  int size = solution[0].length;
  print(size);

  String result = "";
  String defColorValue = "#00FF00";

  result = "$result$size $defColorValue ";

  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      result += solution[i][j].toString();
    }
  }

  print(result);
  return result;
}

class SolvePuzzlesScreen extends StatefulWidget {
  @override
  _SolvePuzzlesScreenState createState() => _SolvePuzzlesScreenState();
}

class _SolvePuzzlesScreenState extends State<SolvePuzzlesScreen> {
  List<Map<String, dynamic>> customPuzzles = [];

  @override
  void initState() {
    super.initState();
    loadCustomPuzzles();
  }

  Future<void> loadCustomPuzzles() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/custom_puzzles.json');

    print('Custom puzzles path: ${file.path}'); // Print directory for debugging

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      setState(() {
        customPuzzles =
            List<Map<String, dynamic>>.from(json.decode(jsonString));
      });
    }
  }

  Future<void> deleteCustomPuzzle(int index) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/custom_puzzles.json');

    setState(() {
      customPuzzles.removeAt(index);
    });

    await file.writeAsString(json.encode(customPuzzles), flush: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solve Puzzles'),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Premade Puzzles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 2, // Number of premade puzzles
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Puzzle ${index + 1}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NonogramBoard(
                            title: 'Puzzle ${index + 1}',
                            solution:
                                index == 0 ? puzzle1Solution : puzzle2Solution,
                            rowClues:
                                index == 0 ? puzzle1RowClues : puzzle2RowClues,
                            columnClues: index == 0
                                ? puzzle1ColumnClues
                                : puzzle2ColumnClues,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Custom Puzzles',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: customPuzzles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title:
                        Text(customPuzzles[index]['name'] ?? 'Unnamed Puzzle'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Delete Puzzle'),
                                content: Text(
                                    'Are you sure you want to delete "${customPuzzles[index]['name']}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await deleteCustomPuzzle(index);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Puzzle deleted successfully')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.qr_code, color: Colors.blue),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => Dialog(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Generated code for the puzzle"),
                                    QRCodeGenerator(
                                        data: generateQRCode(customPuzzles[
                                                index]['solution']
                                            .map<List<int>>((dynamic row) =>
                                                List<int>.from(row.cast<int>()))
                                            .toList()))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NonogramBoard(
                            title: customPuzzles[index]['name'],
                            solution: (customPuzzles[index]['solution'] as List)
                                .map((row) => List<int>.from(row))
                                .toList(),
                            rowClues: (customPuzzles[index]['rowClues'] as List)
                                .map((row) => List<int>.from(row))
                                .toList(),
                            columnClues:
                                (customPuzzles[index]['columnClues'] as List)
                                    .map((col) => List<int>.from(col))
                                    .toList(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
