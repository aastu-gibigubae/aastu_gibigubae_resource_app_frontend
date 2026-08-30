import 'package:flutter/material.dart';
import '../../domain/entities/course_item.dart';
import '../constants/resource_ui_constants.dart';

class CourseStatsBanner extends StatelessWidget {
  final CourseItem course;

  const CourseStatsBanner({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResourceUiConstants.cardBorderRadius),
        border: Border.all(color: ResourceUiConstants.statsBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Resources count
          Expanded(
            child: _buildStatItem(
              topWidget: Text(
                '${course.resourceCount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ResourceUiConstants.textNavy,
                ),
              ),
              label: ResourceUiConstants.resourcesCountLabel,
            ),
          ),
          _buildDivider(),

          // Academic year
          Expanded(
            child: _buildStatItem(
              topWidget: const Icon(
                Icons.school,
                color: ResourceUiConstants.textNavy,
                size: 26,
              ),
              labelWidget: Text(
                '${course.academicYear}${course.academicYear == 1 ? 'st' : 'nd'} Year',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ResourceUiConstants.textNavy,
                ),
              ),
            ),
          ),
          _buildDivider(),

          // Semester
          Expanded(
            child: _buildStatItem(
              topWidget: const Icon(
                Icons.calendar_month,
                color: ResourceUiConstants.textNavy,
                size: 24,
              ),
              labelWidget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.semester,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: ResourceUiConstants.textNavy,
                    ),
                  ),
                  const Text(
                    ResourceUiConstants.semesterLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    Widget? topWidget,
    String? label,
    Widget? labelWidget,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ?topWidget,
        const SizedBox(height: 4),
        if (labelWidget != null)
          labelWidget
        else if (label != null)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: ResourceUiConstants.statsBorderColor,
    );
  }
}
