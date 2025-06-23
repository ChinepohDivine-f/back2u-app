import 'package:intl/intl.dart';

String toTitleCase(String text) {
  if (text.trim().isEmpty) {
    return '';
  }
  return text
      .trim()
      .split(RegExp(r'\s+')) // split by one or more spaces
      .map((word) => word.isNotEmpty
          ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
          : '')
      .join(' ');
}

String formatReward(String rewardValue) {
  if (rewardValue.trim().isEmpty || rewardValue.trim() == '0') {
    return 'No reward';
  }
  final number = int.tryParse(rewardValue.replaceAll(RegExp(r'[^0-9]'), ''));
  if (number != null) {
    final format = NumberFormat.currency(locale: 'fr_CM', symbol: 'XAF', decimalDigits: 0);
    return format.format(number);
  }
  return rewardValue; // Fallback to original value if parsing fails
}

String toSentenceCase(String text) {
  if (text.trim().isEmpty) {
    return '';
  }

  String trimmedText = text.trim();
  // Capitalize the very first letter of the entire text block.
  String result = '${trimmedText[0].toUpperCase()}${trimmedText.substring(1)}';

  // This regex looks for a sentence-ending character (. ! ?)
  // followed by one or more whitespace characters, and then a letter.
  // It uses a positive lookbehind to not consume the matched characters.
  result = result.replaceAllMapped(RegExp(r'([.!?])\s+([a-z])'), (match) {
    // match.group(1) is the punctuation e.g., "."
    // match.group(2) is the letter to be capitalized e.g., "a"
    return '${match.group(1)} ${match.group(2)!.toUpperCase()}';
  });

  return result;
} 