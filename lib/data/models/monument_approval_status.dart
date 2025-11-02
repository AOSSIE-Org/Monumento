enum MonumentApprovalStatus {
  pending,
  approved,
  rejected;

  String get value => name;

  static MonumentApprovalStatus fromString(String value) {
    return MonumentApprovalStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MonumentApprovalStatus.pending,
    );
  }
}
