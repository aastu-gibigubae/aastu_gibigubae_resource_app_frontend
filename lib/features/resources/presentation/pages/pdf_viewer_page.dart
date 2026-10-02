import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/resource_item.dart';

class PdfViewerPage extends StatelessWidget {
  final ResourceItem? resource;
  final String title;
  final String courseName;
  final String? fileUrl;

  const PdfViewerPage({
    super.key,
    this.resource,
    this.title = 'Document',
    this.courseName = 'Course Resource',
    this.fileUrl,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = resource?.title ?? title;
    final effectiveCourseName = resource?.courseName.isNotEmpty == true
        ? resource!.courseName
        : courseName;
    final effectiveFileUrl = resource?.fileUrl ?? fileUrl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top curved Navy Header matching image copy 17.png
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 12,
                20,
                24,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          effectiveCourseName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          effectiveTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (effectiveFileUrl != null && effectiveFileUrl.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'Open full document',
                      onPressed: () async {
                        final uri = Uri.parse(effectiveFileUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // In-app Document Reader canvas matching image copy 17.png
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Document Content Simulation (matching exact mockup structure)
                      Positioned.fill(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(28, 48, 36, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildDocLine(width: 90, height: 16),
                              const SizedBox(height: 22),
                              _buildDocLine(width: 150, height: 16),
                              const SizedBox(height: 22),
                              _buildDocLine(width: 200, height: 16),
                              const SizedBox(height: 22),
                              _buildDocLine(width: 260, height: 16),
                              const SizedBox(height: 22),
                              _buildDocLine(width: 280, height: 16),
                              const SizedBox(height: 22),
                              _buildDocLine(width: 300, height: 16),
                              const SizedBox(height: 36),
                              _buildDocLine(width: 280, height: 14),
                              const SizedBox(height: 16),
                              _buildDocLine(width: 290, height: 14),
                              const SizedBox(height: 16),
                              _buildDocLine(width: 240, height: 14),
                              const SizedBox(height: 16),
                              _buildDocLine(width: 270, height: 14),
                            ],
                          ),
                        ),
                      ),

                      // Right scroll indicator bar matching image copy 17.png
                      Positioned(
                        top: 24,
                        right: 14,
                        bottom: 24,
                        child: Container(
                          width: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              width: 10,
                              height: 110,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCBD5E1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDocLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}
