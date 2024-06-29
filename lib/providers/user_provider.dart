import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user; // Make it nullable

  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  int get userId => _user?.userId ?? 0; // Use null check operator
}
