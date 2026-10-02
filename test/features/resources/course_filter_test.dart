import 'package:flutter_test/flutter_test.dart';
import 'package:aastu_gibigubae_resource_app_frontend/features/resources/domain/entities/course_item.dart';
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

    test('defaults to year 1 for freshman with null streamId', () {
      const p = CoursesParams();
      expect(p.streamId, isNull);
      expect(p.year, 1);
      expect(p.departmentId, isNull);
      expect(p.page, 1);
    });

    test('freshman CourseItem defaults semester to Semester 1 and resources to 16', () {
      const course = CourseItem(
        id: 1,
        departmentId: 1,
        name: 'Communicative English I',
        academicYear: 1,
      );
      expect(course.academicYear, 1);
      expect(course.semester, 'Semester 1');
      expect(course.resourceCount, 16);
    });
  });
}
