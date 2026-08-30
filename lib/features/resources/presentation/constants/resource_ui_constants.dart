import 'package:flutter/material.dart';
import '../../domain/entities/resource_category_type.dart';

class ResourceUiConstants {
  ResourceUiConstants._();

  // Strings
  static const String homeGreeting = 'Hello, Abebe! 👋';
  static const String premiumAccess = 'Premium Access';
  static const String activeStatus = 'Active';
  static const String browseByStream = 'Browse by Stream';
  static const String popularCategories = 'Popular Categories';
  static const String recentActivities = 'Recent Activities';
  static const String seeAll = 'See all';
  static const String searchHint = 'Search courses, resources...';
  static const String browseTitle = 'Browse';
  static const String browseSubtitle = 'Find your course resources';
  static const String freshmanCourses = 'Your Freshman Courses';
  static const String resourceCategories = 'Resource Categories';
  static const String openRead = 'Open/Read';
  static const String downloadPdf = 'Download PDF';
  static const String resourcesCountLabel = 'Resources';
  static const String semesterLabel = 'Semester';

  // Categories List
  static const List<(ResourceCategoryType, String)> categoryPairs = [
    (ResourceCategoryType.handouts, 'Handouts'),
    (ResourceCategoryType.ppts, 'PPTs'),
    (ResourceCategoryType.midterms, 'Midterms'),
    (ResourceCategoryType.assignments, 'Assignments'),
    (ResourceCategoryType.finals, 'Finals'),
    (ResourceCategoryType.modules, 'Modules'),
  ];

  static const List<(ResourceCategoryType, String)> popularCategoryPairs = [
    (ResourceCategoryType.handouts, 'Handouts'),
    (ResourceCategoryType.ppts, 'PPTs'),
    (ResourceCategoryType.midterms, 'Midterms'),
    (ResourceCategoryType.modules, 'Modules'),
    (ResourceCategoryType.finals, 'Finals'),
  ];

  // Layout Constants
  static const double headerCurveRadius = 32.0;
  static const double cardBorderRadius = 20.0;
  static const double tileBorderRadius = 16.0;
  static const double searchBarHeight = 48.0;
  static const double primaryButtonHeight = 52.0;
  static const double horizontalPadding = 16.0;

  // Colors
  static const Color headerNavy = Color(0xFF0D3274);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color textNavy = Color(0xFF1E3A8A);
  static const Color textLink = Color(0xFF1E40AF);
  static const Color streamBg = Color(0xFFEBF2FD);
  static const Color streamIconColor = Color(0xFF2563EB);
  static const Color cardBorderColor = Color(0xFFE5E7EB);
  static const Color statsBorderColor = Color(0xFFE2E8F0);
}
