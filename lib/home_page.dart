import 'package:flutter/material.dart';
import 'nonogram_board.dart';
import 'puzzles.dart';

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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              ),
              child: const Text(
                'Puzzle 2',
                style: TextStyle(fontSize: 18),
              ),
            ),
            // Add more buttons for additional puzzles 
          ],
        ),
      ),
    );
  }
}