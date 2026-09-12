import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../domain/entities/resource_item.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/resource_document_hero.dart';

class ResourceDetailPage extends StatelessWidget {
  // Accepts either a ResourceItem directly or an int ID.
  final ResourceItem? resource;
  final int resourceId;

  const ResourceDetailPage({
    super.key,
    this.resource,
    this.resourceId = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Use the passed resource, or show a placeholder if only an ID was given.
    final res = resource;
    if (res == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Resource'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Resource details unavailable.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Document Hero Graphic
            CurvedHeader(
              showBackButton: true,
              title: res.title,
              heroGraphic: const ResourceDocumentHero(),
            ),

            const SizedBox(height: 20),

            // Resource Metadata Tile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const PdfIconBadge(size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          res.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: ResourceUiConstants.textNavy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          res.courseName.isNotEmpty
                              ? res.courseName
                              : 'Course Resource',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ResourceUiConstants.textNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Locked resource message
            if (res.locked)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(
                        ResourceUiConstants.cardBorderRadius),
                    border: Border.all(
                        color: const Color(0xFFFBBF24), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: Color(0xFFD97706), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          res.message ??
                              'This resource requires premium access.',
                          style: const TextStyle(
                            color: Color(0xFF92400E),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Reading/Preview Container
            if (!res.locked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 240,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        ResourceUiConstants.cardBorderRadius),
                    border: Border.all(
                        color: ResourceUiConstants.statsBorderColor,
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Document Preview & Content',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${res.formattedSize} • Ready to Read Offline',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Primary Open/Read Button
                    SizedBox(
                      width: double.infinity,
                      height: ResourceUiConstants.primaryButtonHeight,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Opening ${res.title} in Reader...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          ResourceUiConstants.openRead,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Secondary Download PDF Button
                    SizedBox(
                      width: double.infinity,
                      height: ResourceUiConstants.primaryButtonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Downloading ${res.title}...'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.file_download_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        label: const Text(
                          ResourceUiConstants.downloadPdf,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
