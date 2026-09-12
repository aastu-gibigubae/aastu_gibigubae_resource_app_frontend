// Matches the backend IssueReportMinimal and IssueReason schemas.
class IssueReportMinimalModel {
  final int id;
  final String status;

  const IssueReportMinimalModel({
    required this.id,
    required this.status,
  });

  factory IssueReportMinimalModel.fromJson(Map<String, dynamic> json) {
    return IssueReportMinimalModel(
      id: json['id'] as int,
      status: json['status'] as String,
    );
  }
}

// Backend-defined issue reasons for resource reports.
enum IssueReason {
  brokenFile('broken_file', 'Broken file'),
  wrongFile('wrong_file', 'Wrong file'),
  incorrectCategory('incorrect_category', 'Incorrect category'),
  poorQuality('poor_quality', 'Poor quality'),
  other('other', 'Other');

  final String apiValue;
  final String label;
  const IssueReason(this.apiValue, this.label);
}
