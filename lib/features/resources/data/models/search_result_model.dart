// Matches the backend SearchResult schema.
// Discriminated by type: 'course' has name, 'resource' has title + locked.
class SearchResultModel {
  final String type;
  final int id;
  final String? name;
  final String? title;
  final bool? locked;

  const SearchResultModel({
    required this.type,
    required this.id,
    this.name,
    this.title,
    this.locked,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      type: json['type'] as String,
      id: json['id'] as int,
      name: json['name'] as String?,
      title: json['title'] as String?,
      locked: json['locked'] as bool?,
    );
  }

  bool get isCourse => type == 'course';
  bool get isResource => type == 'resource';

  String get displayName => name ?? title ?? '';
}
