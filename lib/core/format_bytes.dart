/// A size for people: "512 B", "1.5 KB", "3.2 MB" (decimal, one decimal place
/// from kilobytes up).
String formatBytes(int bytes) {
  if (bytes < 1000) return '$bytes B';
  const units = ['KB', 'MB', 'GB'];
  var value = bytes / 1000;
  var unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit++;
  }
  return '${value.toStringAsFixed(1)} ${units[unit]}';
}
