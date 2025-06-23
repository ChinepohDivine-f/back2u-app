import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), ''); // Remove all non-digits

    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formattedText = '';
    if (text.length > 6) {
      formattedText += '${text.substring(0, 3)} ';
      formattedText += '${text.substring(3, 6)} ';
      formattedText += text.substring(6);
    } else if (text.length > 3) {
      formattedText += '${text.substring(0, 3)} ';
      formattedText += text.substring(3);
    } else {
      formattedText = text;
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
} 