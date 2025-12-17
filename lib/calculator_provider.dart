import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class CalculatorProvider with ChangeNotifier {
  String _expression = '';
  String _result = '0';
  bool _isScientific = false;

  String get expression => _expression;
  String get result => _result;
  bool get isScientific => _isScientific;

  void toggleScientific() {
    _isScientific = !_isScientific;
    notifyListeners();
  }

  void buttonPressed(String buttonText) {
    if (buttonText == 'C') {
      _expression = '';
      _result = '0';
    } else if (buttonText == '=') {
      try {
        String finalExpression = _expression
            .replaceAll('x', '*')
            .replaceAll('÷', '/');
        Parser p = Parser();
        Expression exp = p.parse(finalExpression);
        ContextModel cm = ContextModel();
        _result = exp.evaluate(EvaluationType.REAL, cm).toString();
      } catch (e) {
        _result = 'Error';
      }
    } else {
      if (_expression == "0" && buttonText != '.') {
        _expression = buttonText;
      } else {
        _expression += buttonText;
      }
    }
    notifyListeners();
  }
}
