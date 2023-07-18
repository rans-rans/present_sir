final months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class Formatters {
  static String formatYear(DateTime date) {
    return "${months[date.month]}  ${date.day},  ${date.year}";
  }
}
