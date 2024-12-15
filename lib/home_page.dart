import 'package:flutter/material.dart';
import 'nonogram_board.dart';
import 'puzzles.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'create_puzzle.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Create Puzzle',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        customPuzzles = List<Map<String, dynamic>>.from(json.decode(jsonString));
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
                            solution: index == 0 ? puzzle1Solution : puzzle2Solution,
                            rowClues: index == 0 ? puzzle1RowClues : puzzle2RowClues,
                            columnClues: index == 0 ? puzzle1ColumnClues : puzzle2ColumnClues,
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
                    title: Text(customPuzzles[index]['name'] ?? 'Unnamed Puzzle'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Delete Puzzle'),
                            content: Text('Are you sure you want to delete "${customPuzzles[index]['name']}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await deleteCustomPuzzle(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Puzzle deleted successfully')),
                          );
                        }
                      },
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
                            columnClues: (customPuzzles[index]['columnClues'] as List)
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
