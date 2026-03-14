extension StringExtension on String {
  String capitalize() {
    if (isNotEmpty && length > 1) {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }

    throw Exception("Can't capitalize empty string or smaller than 2 characters string");
  }
}