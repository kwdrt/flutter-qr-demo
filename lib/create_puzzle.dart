import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

class CreatePuzzleScreen extends StatefulWidget {
  @override
  _CreatePuzzleScreenState createState() => _CreatePuzzleScreenState();
}

class _CreatePuzzleScreenState extends State<CreatePuzzleScreen> {
  List<List<int>> boardState = List.generate(9, (_) => List.generate(8, (_) => 0));

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
    final gridSize = (screenWidth - 32) / 8;

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
                children: List.generate(9, (row) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(8, (col) {
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
