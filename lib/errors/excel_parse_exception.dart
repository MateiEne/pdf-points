class ExcelParseException implements Exception {
  final String message;

  const ExcelParseException({required this.message});

  @override
  String toString() {
    return "Exception: $message";
  }
}
