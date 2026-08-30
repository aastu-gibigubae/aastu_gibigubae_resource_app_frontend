import 'package:flutter/material.dart';
import '../../domain/entities/course_item.dart';
import '../../domain/entities/recent_activity_item.dart';
import '../../domain/entities/resource_category_type.dart';
import '../../domain/entities/resource_item.dart';
import '../../domain/entities/stream_item.dart';

class MockResourceDatasource {
  const MockResourceDatasource();

  static const List<StreamItem> streams = [
    StreamItem(
      id: 1,
      name: 'Engineering',
      subtitle: 'Explore Courses',
      icon: Icons.settings,
    ),
    StreamItem(
      id: 2,
      name: 'Applied Science',
      subtitle: 'Explore Courses',
      icon: Icons.science_outlined,
    ),
  ];

  static const List<CourseItem> freshmanCourses = [
    CourseItem(
      id: 1,
      streamId: 1,
      departmentId: 1,
      name: 'Communicative English I',
      academicYear: 1,
      semester: 'Semester 1',
      resourceCount: 16,
      iconKey: 'english',
    ),
    CourseItem(
      id: 2,
      streamId: 1,
      departmentId: 1,
      name: 'Engineering Mathematics I',
      academicYear: 1,
      semester: 'Semester 1',
      resourceCount: 16,
      iconKey: 'math',
    ),
    CourseItem(
      id: 3,
      streamId: 1,
      departmentId: 1,
      name: 'Physics I',
      academicYear: 1,
      semester: 'Semester 1',
      resourceCount: 16,
      iconKey: 'physics',
    ),
    CourseItem(
      id: 4,
      streamId: 1,
      departmentId: 1,
      name: 'Logic & Critical Thinking',
      academicYear: 1,
      semester: 'Semester 1',
      resourceCount: 16,
      iconKey: 'logic',
    ),
    CourseItem(
      id: 5,
      streamId: 1,
      departmentId: 1,
      name: 'Psychology',
      academicYear: 1,
      semester: 'Semester 1',
      resourceCount: 16,
      iconKey: 'psychology',
    ),
  ];

  static const List<RecentActivityItem> recentActivities = [
    RecentActivityItem(
      id: 1,
      title: 'Communicative English I',
      courseName: 'Communicative English I',
      categoryLabel: 'Module',
      academicYear: 1,
      semester: 'Semester 1',
      typeBadge: 'PDF',
      badgeColor: Color(0xFFEF4444),
    ),
    RecentActivityItem(
      id: 2,
      title: 'Psychology',
      courseName: 'Psychology',
      categoryLabel: 'Final Exam',
      academicYear: 1,
      semester: 'Semester 1',
      typeBadge: 'A+',
      badgeColor: Color(0xFF3B82F6),
    ),
    RecentActivityItem(
      id: 3,
      title: 'Logic and Critical Thinking',
      courseName: 'Logic and Critical Thinking',
      categoryLabel: 'PPT',
      academicYear: 1,
      semester: 'Semester 1',
      typeBadge: 'PPT',
      badgeColor: Color(0xFFF97316),
    ),
  ];

  List<ResourceItem> getCategoryResources({
    required int courseId,
    required ResourceCategoryType category,
  }) {
    final course = getCourseById(courseId);

    return List.generate(5, (index) {
      final chapterNum = index + 1;
      return ResourceItem(
        id: (courseId * 100) + chapterNum,
        courseId: courseId,
        title: 'Chapter $chapterNum',
        description:
            'Comprehensive study guide and lecture materials for Chapter $chapterNum.',
        category: category,
        isFreeSample: chapterNum <= 2,
        locked: false,
        fileUrl:
            'https://resource-app-h7e9.onrender.com/resources/sample-$chapterNum.pdf',
        fileSizeBytes: 2516582,
        courseName: course.name,
        semester: course.semester,
        academicYear: course.academicYear,
      );
    });
  }

  CourseItem getCourseById(int courseId) {
    return freshmanCourses.firstWhere(
      (c) => c.id == courseId,
      orElse: () => freshmanCourses.first,
    );
  }

  ResourceItem getResourceById(int id) {
    final chapterNum = (id % 100 > 0) ? id % 100 : 1;
    return ResourceItem(
      id: id,
      courseId: 1,
      title: 'Chapter $chapterNum',
      description: 'Course study material and handouts.',
      category: ResourceCategoryType.handouts,
      isFreeSample: true,
      locked: false,
      fileUrl:
          'https://resource-app-h7e9.onrender.com/resources/sample-$chapterNum.pdf',
      fileSizeBytes: 2516582,
      courseName: 'Communicative English I',
      semester: 'Semester 1',
      academicYear: 1,
    );
  }
}
