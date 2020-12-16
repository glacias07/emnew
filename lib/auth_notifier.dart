import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';

class AuthNotifier with ChangeNotifier {
  // ignore: deprecated_member_use
  FirebaseUser _user;

  // ignore: deprecated_member_use
  FirebaseUser get user => _user;

  // ignore: deprecated_member_use
  void setUser(FirebaseUser user) {
    _user = user;
    notifyListeners();
  }
}