import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  final qrCodes = <String>["noCode", "4 #00FF00 0110111111110111"];

  void addQrCode(qrCode) {
    if (!qrCodes.contains(qrCode)) {
      qrCodes.add(qrCode);
    }
  }
}
