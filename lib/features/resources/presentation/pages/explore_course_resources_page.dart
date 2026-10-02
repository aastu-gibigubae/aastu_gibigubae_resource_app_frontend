import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/resource_item.dart';

class ExploreCourseResourcesPage extends ConsumerWidget {
  const ExploreCourseResourcesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sampleResources = const MockResourceDatasource()
        .getAllResources()
        .where((r) => r.isFreeSample)
        .take(4)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header matching image copy 8.png
            CurvedHeader(
              title: 'Explore Course Resources',
              subtitle: 'Get access to past exams, lecture notes, modules and more.',
              subtitleColor: Colors.white.withAlpha(220),
              trailing: GestureDetector(
                onTap: () => context.push(RouteNames.premium),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.2,
                    ),
                    color: const Color(0xFFF59E0B).withAlpha(25),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Color(0xFFF59E0B)),
                      SizedBox(width: 4),
                      Text(
                        'About Premium',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // "Here's a sneak peek of what you'll get" card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(6),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Here's a sneak peek of what you'll get",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        _SneakPeekItem(
                          label: 'Final Exams',
                          icon: Icons.assignment_turned_in_outlined,
                          color: Color(0xFF2563EB),
                          bgColor: Color(0xFFEFF6FF),
                        ),
                        _SneakPeekItem(
                          label: 'Modules',
                          icon: Icons.menu_book_rounded,
                          color: Color(0xFFD97706),
                          bgColor: Color(0xFFFEF3C7),
                        ),
                        _SneakPeekItem(
                          label: 'Handouts',
                          icon: Icons.folder_open_rounded,
                          color: Color(0xFF0284C7),
                          bgColor: Color(0xFFE0F2FE),
                        ),
                        _SneakPeekItem(
                          label: 'Midterms',
                          icon: Icons.fact_check_outlined,
                          color: Color(0xFF7C3AED),
                          bgColor: Color(0xFFF5F3FF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // "Sample Resources" section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text(
                'Sample Resources',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Sample Resources list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: sampleResources.map((res) {
                  return _SampleResourceCard(
                    resource: res,
                    onTap: () {
                      context.push(RouteNames.resourceDetail, extra: res);
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Bottom Actions: "Get Premium ->" and "Go to Home"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => context.go(RouteNames.home),
                    child: const Text(
                      'Browse App',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.premium),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Get Premium',
                          style: TextStyle(
                            color: Color(0xFF0D3274),
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF0D3274),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SneakPeekItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _SneakPeekItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(50), width: 1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E3A8A),
          ),
        ),
      ],
    );
  }
}

class _SampleResourceCard extends StatelessWidget {
  final ResourceItem resource;
  final VoidCallback onTap;

  const _SampleResourceCard({
    required this.resource,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = resource.fileUrl?.endsWith('.pdf') ?? true;
    final fileTypeLabel = isPdf ? 'PDF' : 'DOC';
    final badgeColor = isPdf ? const Color(0xFFEF4444) : const Color(0xFF3B82F6);
    final badgeBg = isPdf ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    fileTypeLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.courseName.isNotEmpty
                          ? resource.courseName
                          : resource.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${resource.category.label} • 2024 AC',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  fileTypeLabel,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
