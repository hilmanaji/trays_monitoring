import 'package:flutter/foundation.dart';

class SessionCoordinator extends ChangeNotifier {
  int _invalidations = 0;

  int get invalidations => _invalidations;

  void markUnauthorized() {
    _invalidations += 1;
    notifyListeners();
  }
}
