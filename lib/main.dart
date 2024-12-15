import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_test/AppState.dart';
import 'QrCodeGenerator.dart';
import 'QrCodeScanner.dart';
import 'home_page.dart';

/// Flutter code sample for [NavigationBar].

void main() => runApp(const NavigationBarApp());

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
      body: IndexedStack(index: currentPageIndex, children: [
        HomePage(),
        ScanPage(),
        GeneratePage(),
      ]),
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
