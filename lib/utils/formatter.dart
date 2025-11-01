// lib/utils/formatters.dart
import 'package:intl/intl.dart';

String formatKeepApiSign(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  final t = raw.trim();
  String sign = '';
  String numStr = t;

  if (t.startsWith('+') || t.startsWith('-')) {
    sign = t[0];
    numStr = t.substring(1);
  }
  final val = double.tryParse(numStr) ?? 0;
  final formatted = NumberFormat('#,##0.########').format(val);
  return '$sign$formatted';
}
