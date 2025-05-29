enum DocumentType {
  identification,
  vehicle,
  educational,
  financial,
  legal,
  other, // For any documents that don't fit
}

enum ReportStatus {
  missing,
  found,
  resolved,
  pending,
}

enum ReportType {
  lost,
  found,
}