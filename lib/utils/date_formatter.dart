class DateFormatter {
  DateFormatter._();

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _shortMonthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String formatFull(DateTime date) {
    return '${_twoDigits(date.day)} ${_shortMonthNames[date.month - 1]} ${date.year}';
  }

  static String formatDayMonth(DateTime date) {
    return '${_twoDigits(date.day)} ${_shortMonthNames[date.month - 1]}';
  }

  static String formatMonthYear(DateTime date) {
    return '${monthName(date.month)} ${date.year}';
  }

  static String monthName(int month) {
    if (month < 1 || month > 12) return '';
    return _monthNames[month - 1];
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
