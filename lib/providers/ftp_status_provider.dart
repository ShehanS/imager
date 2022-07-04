import 'package:flutter/material.dart';

class FTPStatusProvider with ChangeNotifier {
  String _message = "";

  String get getMessage => _message;

  void setMessage(String message) {
    _message = message;
    notifyListeners();
  }
}
