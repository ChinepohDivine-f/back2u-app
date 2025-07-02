enum DocumentType {
  identification,
  vehicle,
  educational,
  financial,
  legal,
  other, // For any documents that don't fit
}

enum ReportStatus {
  
  found,
  resolved,
  pending,
}

enum ReportType {
  lost,
  found,
}

/// Utility class for handling deep links in the app
class DeepLinks {
  const DeepLinks._();  // Private constructor to prevent instantiation
  
  /// Base URL for the web app
  static const String baseUrl = 'https://https://https://back2u-web-gqmo.vercel.app/';
  
  /// Generates a full URL for a specific report
  /// [reportId] The unique identifier of the report
  static String getReportUrl(String reportId) => '$baseUrl/report/$reportId';
}