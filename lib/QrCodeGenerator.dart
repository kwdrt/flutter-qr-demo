import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';

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