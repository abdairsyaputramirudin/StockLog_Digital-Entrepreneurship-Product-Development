import 'dart:math';

String uid([String prefix = '']) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rnd = Random().nextInt(1 << 32).toRadixString(16);
  return '$prefix${now}_$rnd';
}
