import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/providers/resource_providers.dart';

void main() {
  group('CoursesParams tests', () {
    test('equality and hashcode match when params are identical', () {
      const p1 = CoursesParams(streamId: 1, year: 1, page: 1);
      const p2 = CoursesParams(streamId: 1, year: 1, page: 1);
      const p3 = CoursesParams(streamId: 2, year: 1, page: 1);

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });

    test('accepts null streamId and year as defaults', () {
      const p = CoursesParams();
      expect(p.streamId, isNull);
      expect(p.year, isNull);
      expect(p.departmentId, isNull);
      expect(p.page, 1);
    });
  });
}
