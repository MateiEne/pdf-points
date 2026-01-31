extension IntExtansion on int {
  String toPaddedString(int length) {
    return toString().padLeft(length, '0');
  }
}