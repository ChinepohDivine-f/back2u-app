import 'package:intl/intl.dart';

class DocumentParser {
  static final Map<String, List<RegExp>> _fieldPatterns = {
    'ownerName': [
      RegExp(r'(?:owner|name|proprietor|holder)[\s:]*([a-zA-Z\s\.,-]+)', caseSensitive: false),
      RegExp(r'(?:name\s*on\s*card|card\s*holder)[\s:]*([a-zA-Z\s\.,-]+)', caseSensitive: false),
    ],
    'location': [
      RegExp(r'(?:location|address|place|city|state)[\s:]*([a-zA-Z0-9\s\.,-]+)', caseSensitive: false),
    ],
    'sublocation': [
      RegExp(r'(?:sublocation|area|district|county)[\s:]*([a-zA-Z0-9\s\.,-]+)', caseSensitive: false),
    ],
    'dateIssued': [
      RegExp(r'(?:date\s*issued|issue\s*date|issued\s*on)[\s:]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})', caseSensitive: false),
      RegExp(r'(?:date\s*of\s*issue)[\s:]*([a-zA-Z]+\s+[0-9]{1,2},?\s+[0-9]{4})', caseSensitive: false),
    ],
    'expiryDate': [
      RegExp(r'(?:expir(?:y|ation)|valid\s*until|valid\s*thru)[\s:]*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})', caseSensitive: false),
      RegExp(r'(?:expir(?:y|ation)\s*date)[\s:]*([a-zA-Z]+\s+[0-9]{1,2},?\s+[0-9]{4})', caseSensitive: false),
    ],
    'category': [
      RegExp(r'(?:type\s*of\s*id|id\s*type|document\s*type)[\s:]*([a-zA-Z\s]+)', caseSensitive: false),
    ],
    'subcategory': [
      RegExp(r'(?:subtype|sub\s*category)[\s:]*([a-zA-Z\s]+)', caseSensitive: false),
    ],
  };

  static final List<DateFormat> _dateFormats = [
    DateFormat('MM/dd/yyyy'),
    DateFormat('dd/MM/yyyy'),
    DateFormat('yyyy-MM-dd'),
    DateFormat('MMMM d, yyyy'),
    DateFormat('MMM d, yyyy'),
  ];

  static Map<String, String> parseDocumentText(String text) {
    final result = <String, String>{};
    
    for (final entry in _fieldPatterns.entries) {
      result[entry.key] = _extractField(text, entry.value);
    }
    
    // Additional processing for dates
    result['dateIssued'] = _parseDate(result['dateIssued'] ?? '');
    result['expiryDate'] = _parseDate(result['expiryDate'] ?? '');
    
    return result;
  }

  static String _extractField(String text, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  static String _parseDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    for (final format in _dateFormats) {
      try {
        final date = format.parse(dateStr);
        return DateFormat('yyyy-MM-dd').format(date);
      } catch (e) {
        continue;
      }
    }
    return dateStr; // Return original if no format matches
  }

  static bool compareDocumentData(Map<String, dynamic> extracted, Map<String, dynamic> expected) {
    final fields = expected.keys.toList();
    int matchCount = 0;
    
    for (final field in fields) {
      final extractedValue = extracted[field]?.toString().toLowerCase().trim() ?? '';
      final expectedValue = expected[field]?.toString().toLowerCase().trim() ?? '';
      
      if (extractedValue.isEmpty || expectedValue.isEmpty) continue;
      
      if (_isDateField(field)) {
        if (_compareDates(extractedValue, expectedValue)) {
          matchCount++;
        }
      } else if (_isNameField(field)) {
        if (_compareNames(extractedValue, expectedValue)) {
          matchCount++;
        }
      } else if (_fuzzyMatch(extractedValue, expectedValue) > 0.7) {
        matchCount++;
      }
    }
    
    // Consider it a match if at least 70% of fields match
    return (matchCount / fields.length) >= 0.7;
  }

  static bool _isDateField(String field) {
    return field.toLowerCase().contains('date');
  }

  static bool _isNameField(String field) {
    return field.toLowerCase().contains('name');
  }

  static bool _compareDates(String date1, String date2) {
    try {
      final d1 = DateTime.parse(date1);
      final d2 = DateTime.parse(date2);
      return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
    } catch (e) {
      return date1 == date2;
    }
  }

  static bool _compareNames(String name1, String name2) {
    // Simple name comparison - could be enhanced with more sophisticated logic
    final name1Parts = name1.split(RegExp(r'\s+'));
    final name2Parts = name2.split(RegExp(r'\s+'));
    
    // Check if all parts of one name exist in the other
    return name1Parts.every((part) => name2.contains(part)) || 
           name2Parts.every((part) => name1.contains(part));
  }

  static double _fuzzyMatch(String s1, String s2) {
    // Simple Levenshtein distance ratio
    if (s1 == s2) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final distance = _levenshteinDistance(s1, s2);
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    return 1 - (distance / maxLength);
  }

  static int _levenshteinDistance(String s, String t) {
    // Implementation of Levenshtein distance
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < t.length + 1; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }

      for (int j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }

    return v1[t.length];
  }
}