// lib/models/edit_suggestion.dart
enum SuggestionStatus { pending, accepted, rejected }

class EditSuggestion {
  final String id;
  final String monumentId;
  final String suggestedByUserId;
  final String fieldName;
  final String? currentValue;
  final String suggestedValue;
  final String? reason;
  final SuggestionStatus status;
  final DateTime suggestedAt;

  EditSuggestion({
    required this.id,
    required this.monumentId,
    required this.suggestedByUserId,
    required this.fieldName,
    this.currentValue,
    required this.suggestedValue,
    this.reason,
    required this.status,
    required this.suggestedAt,
  });

  factory EditSuggestion.fromJson(Map<String, dynamic> json) {
    return EditSuggestion(
      id: json['\$id'] ?? '',
      monumentId: json['monumentId'] ?? '',
      suggestedByUserId: json['suggestedByUserId'] ?? '',
      fieldName: json['fieldName'] ?? '',
      currentValue: json['currentValue'],
      suggestedValue: json['suggestedValue'] ?? '',
      reason: json['reason'],
      status: SuggestionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SuggestionStatus.pending,
      ),
      suggestedAt: DateTime.parse(json['suggestedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monumentId': monumentId,
      'suggestedByUserId': suggestedByUserId,
      'fieldName': fieldName,
      'currentValue': currentValue,
      'suggestedValue': suggestedValue,
      'reason': reason,
      'status': status.name,
      'suggestedAt': suggestedAt.toIso8601String(),
    };
  }
}
