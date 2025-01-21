import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class CreatePuzzleScreen extends StatefulWidget {
  @override
  _CreatePuzzleScreenState createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Board Size'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Board Size',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PuzzleBoard(size: 5),
                  ),
                );
              },
              child: const Text('5x5'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PuzzleBoard(size: 10),
                  ),
                );
              },
              child: const Text('10x10'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PuzzleBoard(size: 15),
                  ),
                );
              },
              child: const Text('15x15'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                TextEditingController heightController = TextEditingController();
                TextEditingController widthController = TextEditingController();

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Custom Size'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: heightController,
                          decoration: const InputDecoration(hintText: 'Enter height'),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: widthController,
                          decoration: const InputDecoration(hintText: 'Enter width'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          final height = int.tryParse(heightController.text);
                          final width = int.tryParse(widthController.text);
                          if (height != null && width != null && height > 0 && width > 0) {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PuzzleBoard(size: height > width ? height : width),
                              ),
                            );
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Custom Size'),
            ),
          ],
        ),
      ),
    );
  }
}

class PuzzleBoard extends StatefulWidget {
  final int size;

  const PuzzleBoard({Key? key, required this.size}) : super(key: key);

  @override
  _PuzzleBoardState createState() => _PuzzleBoardState();
}

class _PuzzleBoardState extends State<PuzzleBoard> {
  late List<List<int>> boardState;

  @override
  void initState() {
    super.initState();
    boardState = List.generate(widget.size, (_) => List.generate(widget.size, (_) => 0));
  }

  List<List<int>> generateRowClues(List<List<int>> board) {
    return board.map((row) {
      List<int> clues = [];
      int count = 0;
      for (int cell in row) {
        if (cell == 1) {
          count++;
        } else if (count > 0) {
          clues.add(count);
          count = 0;
        }
      }
      if (count > 0) clues.add(count);
      return clues.isEmpty ? [0] : clues;
    }).toList();
  }

  List<List<int>> generateColumnClues(List<List<int>> board) {
    int cols = board[0].length;
    return List.generate(cols, (col) {
      List<int> clues = [];
      int count = 0;
      for (int row = 0; row < board.length; row++) {
        if (board[row][col] == 1) {
          count++;
        } else if (count > 0) {
          clues.add(count);
          count = 0;
        }
      }
      if (count > 0) clues.add(count);
      return clues.isEmpty ? [0] : clues;
    });
  }

  Future<void> savePuzzleToFile(String puzzleName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/custom_puzzles.json');

    List<Map<String, dynamic>> puzzles = [];
    if (await file.exists()) {
      final jsonString = await file.readAsString();
      puzzles = List<Map<String, dynamic>>.from(json.decode(jsonString));
    }

    List<List<int>> rowClues = generateRowClues(boardState);
    List<List<int>> columnClues = generateColumnClues(boardState);

    puzzles.add({
      'name': puzzleName,
      'solution': boardState,
      'rowClues': rowClues,
      'columnClues': columnClues,
      'solved': false,
    });

    await file.writeAsString(json.encode(puzzles), flush: true);
    print('Puzzle saved to: ${file.path}');
  }

  void savePuzzle(BuildContext context) {
    TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Puzzle'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Enter puzzle name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                savePuzzleToFile(nameController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = (screenWidth - 32) / widget.size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Puzzle'),
        backgroundColor: Colors.amber,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Column(
                children: List.generate(widget.size, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.size, (col) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            boardState[row][col] = boardState[row][col] == 0 ? 1 : 0;
                          });
                        },
                        child: Container(
                          width: gridSize,
                          height: gridSize,
                          decoration: BoxDecoration(
                            color: boardState[row][col] == 1 ? Colors.orange : Colors.white,
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => savePuzzle(context),
                child: const Text('Save Puzzle'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
