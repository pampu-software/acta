String generateFingerprint(dynamic error, StackTrace? stack) {
  final errorType = error.runtimeType.toString();

  // Get first line of the stack (top frame)
  final stackLines = stack.toString().split('\n');
  final topFrame = stackLines.isNotEmpty ? stackLines.first.trim() : '';

  // Optional: normalize error message (remove numbers, UUIDs, etc)
  String errorMessage = error.toString().replaceAll(RegExp(r'\d+'), '#');

  // Build fingerprint input
  final rawFingerprint = '$errorType|$errorMessage|$topFrame';

  // Hash it (short + unique)
  final hash = simpleHash(rawFingerprint).toString();
  return hash;
}

int simpleHash(String input) {
  int hash = 0;
  for (var code in input.codeUnits) {
    hash = (hash * 31 + code) & 0x7fffffff; // basic polynomial rolling hash
  }
  return hash;
}
