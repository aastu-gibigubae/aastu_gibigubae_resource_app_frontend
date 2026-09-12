// Backend resource categories: test, midterm, final, ppt, module, handout.
enum ResourceCategoryType {
  handouts('Handouts', 'handout'),
  ppts('PPTs', 'ppt'),
  midterms('Midterms', 'midterm'),
  tests('Tests', 'test'),
  finals('Finals', 'final'),
  modules('Modules', 'module');

  final String label;
  final String apiValue;
  const ResourceCategoryType(this.label, this.apiValue);

  static ResourceCategoryType fromString(String val) {
    return ResourceCategoryType.values.firstWhere(
      (e) =>
          e.apiValue.toLowerCase() == val.toLowerCase() ||
          e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ResourceCategoryType.handouts,
    );
  }
}
