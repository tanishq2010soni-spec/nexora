import 'package:flutter/foundation.dart';

class CharacterProvider extends ChangeNotifier {
  String _expression = 'idle';
  String? _message;
  bool _isAnimating = false;

  String get expression => _expression;
  String? get message => _message;
  bool get isAnimating => _isAnimating;

  void setExpression(String expr) {
    if (_expression != expr) {
      _expression = expr;
      notifyListeners();
    }
  }

  void setMessage(String? msg) {
    _message = msg;
    notifyListeners();
  }

  void startTalking() {
    _expression = 'talking';
    _isAnimating = true;
    notifyListeners();
  }

  void stopTalking() {
    _expression = 'idle';
    _isAnimating = false;
    notifyListeners();
  }

  void startThinking() {
    _expression = 'thinking';
    _isAnimating = true;
    notifyListeners();
  }

  void stopThinking() {
    _expression = 'idle';
    _isAnimating = false;
    notifyListeners();
  }
}
