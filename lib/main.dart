import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_test/QrCodeScanner.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(const NavigationBarApp());

class AppState extends ChangeNotifier {
  final qrCodes = <String>["testValue1", "testValue2", "testValue3"];

  void addQrCode(qrCode) {
    if (!qrCodes.contains(qrCode)) {
      qrCodes.add(qrCode);
    }
  }
}

class NavigationBarApp extends StatelessWidget {
  const NavigationBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>(
      create: (context) => AppState(),
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: const NavigationExample(),
      ),
    );
  }
}

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.qr_code),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan codes',
          ),
          NavigationDestination(
            icon: Icon(Icons.handyman),
            label: 'Create codes',
          ),
        ],
      ),
      body: <Widget>[
        /// Home page
        HomePage(),
        ScanPage(),
        GeneratePage(),
      ][currentPageIndex],
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var qrCodes = appState.qrCodes;

    return Column(
      children: [
        SizedBox(
          height: 200.0,
          child: ListView(
            shrinkWrap: true,
            children: [for (var code in qrCodes) Text(code)],
          ),
        ),
        NonogramBoard(),
      ],
    );
  }
}

class ScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppState>();
    var addCode = appState.addQrCode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => QrCodeScanner(setResult: addCode),
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Scan", style: TextStyle(fontSize: 50.0)),
            ),
          )
        ],
      ),
    );
  }
}

class GeneratePage extends StatefulWidget {
  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  var _qr_code_content = "";

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 300.0,
            child: TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter code content',
              ),
              onSubmitted: (value) {
                setState(() {
                  _qr_code_content = value;
                });
              },
            ),
          ),
          Text(_qr_code_content),
          QRCodeGenerator(data: _qr_code_content),
        ],
      ),
    );
  }
}

class QRCodeGenerator extends StatelessWidget {
  const QRCodeGenerator({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
    );
  }
}

class NonogramBoard extends StatelessWidget {
  final int size = 8;

  const NonogramBoard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: size * 60,
        child: Center(
          child: GridView.count(
            crossAxisCount: size,
            padding: EdgeInsets.all(10),
            mainAxisSpacing: 1.0,
            crossAxisSpacing: 1.0,
            children: [
              for (var i = 0; i < size * size; i++)
                NonogramTile(color: i % 3 == 0 ? Colors.red : Colors.white)
            ],
          ),
        ),
      ),
    );
  }
}

class NonogramTile extends StatefulWidget {
  final Color color;

  const NonogramTile({super.key, required this.color});

  @override
  State<NonogramTile> createState() => _NonogramTileState();
}

class _NonogramTileState extends State<NonogramTile> {
  //random init value
  Color currentColor = Colors.green;

  @override
  void initState() {
    super.initState();
    currentColor = widget.color;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          print(currentColor);
          if (currentColor == Colors.blue) {
            currentColor = Colors.white;
          } else {
            currentColor = Colors.blue;
          }
        });
        //should also update a global state of nonogram board);
      },
      child: Container(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: currentColor,
            border: Border.all(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
