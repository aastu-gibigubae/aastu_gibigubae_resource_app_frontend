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
      departmentId: 1,
      name: 'Communicative English I',
      academicYear: 1,
      iconKey: 'english',
    ),
    CourseItem(
      id: 2,
      departmentId: 1,
      name: 'Engineering Mathematics I',
      academicYear: 1,
      iconKey: 'math',
    ),
    CourseItem(
      id: 3,
      departmentId: 1,
      name: 'Physics I',
      academicYear: 1,
      iconKey: 'physics',
    ),
    CourseItem(
      id: 4,
      departmentId: 1,
      name: 'Logic & Critical Thinking',
      academicYear: 1,
      iconKey: 'logic',
    ),
    CourseItem(
      id: 5,
      departmentId: 1,
      name: 'Psychology',
      academicYear: 1,
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

    switch (category) {
      case ResourceCategoryType.midterms:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: '${course.name} - 2024 Midterm Exam (with Solutions)',
            description:
                'Official midterm examination paper with complete step-by-step answer key.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/midterm-2024.pdf',
            fileSizeBytes: 3145728,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: '${course.name} - 2023 Midterm Exam Paper',
            description:
                'Previous year regular semester midterm questions and problem breakdown.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/midterm-2023.pdf',
            fileSizeBytes: 2451000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: '${course.name} - 2022 Midterm Exam & Explanations',
            description:
                'Past midterm test with annotated lecturer notes and common pitfalls.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/midterm-2022.pdf',
            fileSizeBytes: 2890000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Midterm Model Practice Exam',
            description:
                'High-yield practice problems designed specifically for midterm preparation.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/midterm-model.pdf',
            fileSizeBytes: 1980000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Midterm Rapid Revision Formula & Concept Sheet',
            description:
                'Condensed cheat sheet summarizing all formulas and theorems tested on midterm.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/midterm-summary.pdf',
            fileSizeBytes: 1540000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];

      case ResourceCategoryType.finals:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: '${course.name} - 2024 Final Examination Paper',
            description:
                'Comprehensive 2024 end-of-semester final exam paper.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/final-2024.pdf',
            fileSizeBytes: 4194304,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: '${course.name} - 2023 Final Exam & Marking Guide',
            description:
                'Past final exam questions with detailed mark scheme and solution guidelines.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/final-2023.pdf',
            fileSizeBytes: 3670000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: '${course.name} - 2022 Final Exam with Worked Steps',
            description:
                'Complete solved past paper covering all curriculum chapters.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/final-2022.pdf',
            fileSizeBytes: 3950000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Department Model Final Exam Paper',
            description:
                'Simulated examination crafted by university instructors for final preparation.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/final-model.pdf',
            fileSizeBytes: 2800000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Comprehensive 5-Year Past Questions Bank',
            description:
                'Archived collection of previous examination problems organized by topic.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/final-question-bank.pdf',
            fileSizeBytes: 5200000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];

      case ResourceCategoryType.tests:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: 'Quiz 1: Fundamentals & Conceptual Review',
            description:
                'Short test covering introductory units with answer key.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/quiz-1.pdf',
            fileSizeBytes: 1250000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: 'Quiz 2: Analytical & Calculation Problems',
            description:
                'Weekly classroom assessment problems and sample solutions.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/quiz-2.pdf',
            fileSizeBytes: 1420000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: 'Class Test 1: Mid-Chapter Review (with Key)',
            description:
                'Full assessment paper with scoring breakdown.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/test-1.pdf',
            fileSizeBytes: 1680000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Class Test 2: Advanced Problem Solving',
            description:
                'In-depth test questions challenging higher-order understanding.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/test-2.pdf',
            fileSizeBytes: 1850000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Self-Assessment & Mock Test Bundle',
            description:
                'Practice quizzes with detailed explanations for self-evaluation.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/test-bundle.pdf',
            fileSizeBytes: 2100000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];

      case ResourceCategoryType.modules:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: 'Official MoE Course Module (Part 1: Ch 1-3)',
            description:
                'National curriculum textbook and primary course module prescribed by MoE.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/module-part1.pdf',
            fileSizeBytes: 6291456,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: 'Official MoE Course Module (Part 2: Ch 4-6)',
            description:
                'Second half of the official standard course textbook and practical exercises.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/module-part2.pdf',
            fileSizeBytes: 5850000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: 'Recommended Reference Textbook',
            description:
                'Authoritative international textbook recommended for further reading.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/textbook.pdf',
            fileSizeBytes: 8900000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Complete Course Syllabus & Guide',
            description:
                'Detailed weekly breakdown, learning objectives, and reading schedule.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/syllabus.pdf',
            fileSizeBytes: 1200000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Laboratory Manual & Experiments',
            description:
                'Experimental procedures, safety protocols, and lab report templates.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lab-manual.pdf',
            fileSizeBytes: 3400000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];

      case ResourceCategoryType.ppts:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: 'Lecture 1-3: Introduction & Core Foundations',
            description:
                'Classroom slide presentation used during the first 3 weeks of lectures.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lecture-part1.pdf',
            fileSizeBytes: 3100000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: 'Lecture 4-6: Intermediate Concepts & Methods',
            description:
                'Slide deck explaining practical applications and worked illustrations.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lecture-part2.pdf',
            fileSizeBytes: 3450000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: 'Lecture 7-9: Advanced Theories & Proofs',
            description:
                'Comprehensive slides presenting higher-level theorems and diagrams.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lecture-part3.pdf',
            fileSizeBytes: 4200000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Lecture 10-12: Applied Cases & Review',
            description:
                'End-of-term presentation series covering case studies and summary.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lecture-part4.pdf',
            fileSizeBytes: 3800000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Full Semester Presentation Slide Pack',
            description:
                'Combined slide pack with all lecture slides and instructor annotations.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/lecture-fullpack.pdf',
            fileSizeBytes: 9500000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];

      case ResourceCategoryType.handouts:
      default:
        return [
          ResourceItem(
            id: (courseId * 100) + 1,
            courseId: courseId,
            title: 'Chapter 1: Introductory Lecture Notes',
            description:
                'Complete course notes covering foundational definitions and examples.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/handout-ch1.pdf',
            fileSizeBytes: 2100000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 2,
            courseId: courseId,
            title: 'Chapter 2: In-Depth Study Guide',
            description:
                'Structured summary with step-by-step problem-solving methods.',
            category: category,
            isFreeSample: true,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/handout-ch2.pdf',
            fileSizeBytes: 2650000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 3,
            courseId: courseId,
            title: 'Chapter 3: Advanced Concepts & Exercises',
            description:
                'Advanced topic breakdown with selected textbook exercises.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/handout-ch3.pdf',
            fileSizeBytes: 2890000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 4,
            courseId: courseId,
            title: 'Chapter 4: Practical Applications Handout',
            description:
                'Real-world problem sets, diagrams, and illustrative examples.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/handout-ch4.pdf',
            fileSizeBytes: 3100000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
          ResourceItem(
            id: (courseId * 100) + 5,
            courseId: courseId,
            title: 'Chapter 5: Summary & Revision Sheet',
            description:
                'End-of-unit review sheet and quick reference formula sheet.',
            category: category,
            isFreeSample: false,
            fileUrl:
                'https://resource-app-h7e9.onrender.com/resources/handout-ch5.pdf',
            fileSizeBytes: 1950000,
            courseName: course.name,
            semester: course.semester,
            academicYear: course.academicYear,
          ),
        ];
    }
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
