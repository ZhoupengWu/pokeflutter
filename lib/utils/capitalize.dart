extension StringExtension on String {
  /// Upper-cases the first character and lower-cases the rest.
  /// Empty and single-character strings are handled gracefully.
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
