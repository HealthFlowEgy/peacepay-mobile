// utils/helpers.dart  (rename/path as you prefer)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../backend/services/api_endpoint.dart';
import '../utils/basic_widget_imports.dart';

/// ---------- String Extensions ----------
extension NumberParsing on String {
  int parseInt() => int.parse(this);
  double parseDouble() => double.parse(this);

// ⚠️ Highly error-prone for non-numeric strings (like ISO dates).
// Recommend removing to avoid accidental misuse with timestamps.
// get toDouble => double.parse(this);
}

extension EndPointExtensions on String {
  String addBaseURl() => ApiEndpoint.baseUrl + this;

// Duplicate of NumberParsing.parseDouble; remove to avoid confusion.
// double parseDouble() => double.parse(this);
}

/// ---------- Colors ----------
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

/// ---------- Balance helpers (numeric only) ----------
String makeBalance(String value, [int end = 2]) {
  return double.parse(value).toStringAsFixed(end);
}

String makeMultiplyBalance(String value1, String value2, [int end = 2]) {
  return (double.parse(value1) * double.parse(value2)).toStringAsFixed(end);
}

/// ---------- Date/Time helpers ----------
DateTime _toLocalDateTime(dynamic v) {
  // Accept DateTime / epoch millis / String
  if (v is DateTime) return v.toLocal();
  if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
  if (v is String) {
    // 1) ISO-8601 (handles Z/offset)
    final iso = DateTime.tryParse(v);
    if (iso != null) return iso.toLocal();

    // 2) Fix mixed format like "yyyy-MM-dd 17:55 PM"
    final m = RegExp(
      r'^(\d{4}-\d{2}-\d{2})\s+(\d{2}):(\d{2})\s*(AM|PM)$',
      caseSensitive: false,
    ).firstMatch(v);
    if (m != null) {
      final date = m.group(1)!;
      var hh = int.parse(m.group(2)!);
      final mm = m.group(3)!;
      final ampm = m.group(4)!.toUpperCase();
      if (hh > 12) hh -= 12;    // normalize 24h with AM/PM
      if (hh == 0) hh = 12;     // 00 -> 12
      final normalized = '$date ${hh.toString().padLeft(2, '0')}:$mm $ampm';
      return DateFormat('yyyy-MM-dd hh:mm a').parse(normalized, true).toLocal();
    }

    // 3) Common plain formats
    final plain24 = DateFormat('yyyy-MM-dd HH:mm').tryParse(v, true);
    if (plain24 != null) return plain24.toLocal();
    final plain12 = DateFormat('yyyy-MM-dd hh:mm a').tryParse(v, true);
    if (plain12 != null) return plain12.toLocal();
  }
  throw FormatException('Unsupported date format: $v');
}

/// Keeps your original API (returns day/month/year)
Map<String, dynamic> getDate(dynamic dateInput) {
  final dt = _toLocalDateTime(dateInput);
  return {
    "day": dt.day,
    "month": _getMonthName(dt.month),
    "year": dt.year,
  };
}

/// New: returns both date and time in multiple ready-to-use forms.
Map<String, String> getDateTimeParts(dynamic dateInput) {
  final dt = _toLocalDateTime(dateInput);
  return {
    // parts
    "day": dt.day.toString().padLeft(2, '0'),
    "monthNumber": dt.month.toString().padLeft(2, '0'),
    "monthName": _getMonthName(dt.month),
    "year": dt.year.toString(),
    "HHmm": DateFormat('HH:mm').format(dt),        // 24h
    "hhmmA": DateFormat('hh:mm a').format(dt),     // 12h

    // full strings
    "dateYMD": DateFormat('yyyy-MM-dd').format(dt),
    "dateDMY": DateFormat('dd MMM yyyy').format(dt),
    "dateTime24": DateFormat('dd MMM yyyy HH:mm').format(dt),
    "dateTime12": DateFormat('dd MMM yyyy hh:mm a').format(dt),
  };
}

/// One-liner for UI: "06 Oct 2025 17:55" (24h) or "06 Oct 2025 05:55 PM"
String formatDateTime(dynamic dateInput, {bool twelveHour = false}) {
  final dt = _toLocalDateTime(dateInput);
  return DateFormat(twelveHour ? 'dd MMM yyyy hh:mm a' : 'dd MMM yyyy HH:mm')
      .format(dt);
}

String _getMonthName(int month) {
  switch (month) {
    case 1:  return "January";
    case 2:  return "February";
    case 3:  return "March";
    case 4:  return "April";
    case 5:  return "May";
    case 6:  return "June";
    case 7:  return "July";
    case 8:  return "August";
    case 9:  return "September";
    case 10: return "October";
    case 11: return "November";
    case 12: return "December";
    default: return "";
  }
}
