import 'dart:convert';

class IdGenerator {
  IdGenerator._();

  static String generate() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final rand = _randomPart();
    return '$now$rand';
  }

  static String _randomPart() {
    final seed = DateTime.now().microsecond * 9973;
    final bytes = utf8.encode('savora-$seed');
    final code = bytes.fold<int>(0, (a, b) => (a * 31 + b) & 0xFFFFFFFF);
    return (code % 100000).toString().padLeft(5, '0');
  }
}
