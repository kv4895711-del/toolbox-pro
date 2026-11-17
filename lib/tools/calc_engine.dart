import 'dart:math' as math;

String fmtNum(num n) {
  final v = n.toDouble();
  if (v.isNaN || v.isInfinite) return 'Error';
  if (v != 0 && (v.abs() >= 1e15 || v.abs() < 1e-8)) {
    return v.toStringAsExponential(6);
  }
  if (v == v.roundToDouble()) return v.toInt().toString();
  var t = v.toStringAsFixed(8);
  t = t.replaceFirst(RegExp(r'0+$'), '');
  return t.replaceFirst(RegExp(r'\.$'), '');
}

class CalcEngine {
  static double? eval(String expr, {bool deg = true}) {
    final s = expr
        .replaceAll('−', '-')
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('π', 'pi')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll(' ', '')
        .toLowerCase();
    if (s.isEmpty) return null;
    try {
      final v = _Parser(s, deg).parse();
      if (v.isNaN || v.isInfinite) return v;
      return double.parse(v.toStringAsPrecision(12));
    } catch (_) {
      return null;
    }
  }
}

bool _isDigit(String ch) =>
    ch.isNotEmpty && ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;

bool _isLetter(String ch) =>
    ch.isNotEmpty && ch.codeUnitAt(0) >= 97 && ch.codeUnitAt(0) <= 122;

class _Parser {
  final String s;
  final bool deg;
  int i = 0;
  _Parser(this.s, this.deg);

  String get c => i < s.length ? s[i] : '';

  double parse() {
    final v = _expr();
    if (i != s.length) throw const FormatException('bad');
    return v;
  }

  double _expr() {
    var v = _term();
    while (c == '+' || c == '-') {
      final o = c;
      i++;
      final r = _term();
      v = o == '+' ? v + r : v - r;
    }
    return v;
  }

  bool get _startsOperand =>
      c == '(' || c == '.' || c == '√' || _isDigit(c) || _isLetter(c);

  double _term() {
    var v = _unary();
    while (true) {
      if (c == '*' || c == '/') {
        final o = c;
        i++;
        final r = _unary();
        v = o == '*' ? v * r : v / r;
      } else if (_startsOperand) {
        v *= _unary();
      } else {
        return v;
      }
    }
  }

  double _unary() {
    if (c == '-') {
      i++;
      return -_unary();
    }
    if (c == '+') {
      i++;
      return _unary();
    }
    return _power();
  }

  double _power() {
    final b = _postfix();
    if (c == '^') {
      i++;
      return math.pow(b, _unary()).toDouble();
    }
    return b;
  }

  double _postfix() {
    var v = _primary();
    while (c == '!' || c == '%') {
      v = c == '!' ? _fact(v) : v / 100;
      i++;
    }
    return v;
  }

  double _fact(double v) {
    if (v < 0 || v != v.roundToDouble() || v > 170) return double.nan;
    var r = 1.0;
    for (var k = 2; k <= v; k++) {
      r *= k;
    }
    return r;
  }

  double _arg() {
    if (c == '-') {
      i++;
      return -_arg();
    }
    return c == '(' ? _primary() : _postfix();
  }

  double _primary() {
    if (c == '(') {
      i++;
      final v = _expr();
      if (c == ')') i++;
      return v;
    }
    if (c == '√') {
      i++;
      return _sqrt(_arg());
    }
    if (_isLetter(c)) {
      final st = i;
      while (_isLetter(c)) {
        i++;
      }
      return _named(s.substring(st, i));
    }
    final st = i;
    while (_isDigit(c) || c == '.') {
      i++;
    }
    if (st == i) throw const FormatException('num');
    return double.parse(s.substring(st, i));
  }

  double _sqrt(double x) => x < 0 ? double.nan : math.sqrt(x);

  double _r(double v) => v.abs() < 1e-12 ? 0.0 : v;

  double _named(String n) {
    if (n == 'pi') return math.pi;
    if (n == 'e') return math.e;
    final x = _arg();
    final k = deg ? math.pi / 180 : 1.0;
    switch (n) {
      case 'sin':
        return _r(math.sin(x * k));
      case 'cos':
        return _r(math.cos(x * k));
      case 'tan':
        return _r(math.tan(x * k));
      case 'asin':
        return math.asin(x) / k;
      case 'acos':
        return math.acos(x) / k;
      case 'atan':
        return math.atan(x) / k;
      case 'ln':
        return math.log(x);
      case 'log':
        return math.log(x) / math.ln10;
      case 'sqrt':
        return _sqrt(x);
      case 'abs':
        return x.abs();
      case 'exp':
        return math.exp(x);
    }
    throw const FormatException('fn');
  }
}
