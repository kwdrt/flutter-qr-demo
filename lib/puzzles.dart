  // Solution 1
  final List<List<int>> puzzle1Solution = [
    [0, 1, 1, 1, 0, 0, 0, 0],
    [1, 1, 0, 1, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 1, 1],
    [0, 0, 1, 1, 0, 0, 1, 1],
    [0, 0, 1, 1, 1, 1, 1, 1],
    [1, 0, 1, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 1, 0, 0, 0],
  ];

  final List<List<int>> puzzle1RowClues = [
    [3],
    [2, 1],
    [3, 2],
    [2, 2],
    [6],
    [1, 5],
    [6],
    [1],
    [2],
  ];

  final List<List<int>> puzzle1ColumnClues = [
    [1, 2],
    [3, 1],
    [1, 5],
    [7, 1],
    [5],
    [3],
    [4],
    [3],
  ];

  // Solution 2
  final List<List<int>> puzzle2Solution = [
    [0, 0, 0, 0, 1, 1, 1, 0],
    [0, 0, 0, 1, 1, 0, 1, 1],
    [0, 0, 0, 1, 0, 1, 0, 1],
    [0, 0, 0, 1, 1, 0, 1, 1],
    [0, 0, 0, 0, 1, 1, 1, 0],
    [0, 1, 1, 0, 0, 1, 0, 0],
    [0, 1, 1, 1, 0, 1, 0, 0],
    [0, 0, 1, 1, 1, 1, 0, 0],
    [0, 0, 0, 1, 1, 1, 0, 0],
];

  final List<List<int>> puzzle2RowClues = [
    [3],
    [2, 2],
    [1, 1, 1],
    [2, 2],
    [3],
    [2, 1],
    [3, 1],
    [4],
    [3],
  ];

  final List<List<int>> puzzle2ColumnClues = [
    [0],
    [2],
    [3],
    [3, 3],
    [2, 2, 2],
    [1, 1, 5],
    [2, 2],
    [3],
  ];