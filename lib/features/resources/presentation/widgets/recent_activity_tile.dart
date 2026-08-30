import 'package:flutter/material.dart';
import '../../domain/entities/recent_activity_item.dart';
import '../constants/resource_ui_constants.dart';

class RecentActivityTile extends StatelessWidget {
  final RecentActivityItem activity;
  final VoidCallback onTap;

  const RecentActivityTile({
    super.key,
    required this.activity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                _buildBadge(activity),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ResourceUiConstants.textNavy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${activity.categoryLabel} • Year ${activity.academicYear} • ${activity.semester}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ],
      ),
    );
  }

  Widget _buildBadge(RecentActivityItem act) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: act.badgeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: act.badgeColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            act.typeBadge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
