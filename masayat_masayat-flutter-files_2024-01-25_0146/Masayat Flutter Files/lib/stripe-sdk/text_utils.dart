bool isDigit(String s) {
  return int.tryParse(s) != null;
}

bool isDigitsOnly(String s) {
  return int.tryParse(s) != null;
}

int? getNumericValue(String s) {
  return int.tryParse(s);
}
