import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../../../core/widgets/curved_header.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../constants/resource_ui_constants.dart';
import '../widgets/resource_document_hero.dart';

class ResourceDetailPage extends ConsumerWidget {
  final ResourceItem? resource;
  final int resourceId;

  const ResourceDetailPage({
    super.key,
    this.resource,
    this.resourceId = 0,
  });

  Future<void> _openInBrowser(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open file.')),
      );
    }
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not start download.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            color: Colors.grey,
                          ),
                        ),
                        if (!res.locked && res.fileSizeBytes > 0) ...[
                          const SizedBox(height: 3),
                          Text(
                            res.formattedSize,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Locked Warning Banner (if resource is locked)
            if (res.locked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withAlpha(80),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              res.reasonCode != null
                                  ? _reasonLabel(res.reasonCode!)
                                  : 'Access Restricted',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF92400E),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              res.message?.isNotEmpty == true
                                  ? res.message!
                                  : 'This resource requires an active subscription and verified device.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Document Preview Container
            if (!res.locked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
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
                          'Document Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          res.formattedSize,
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

              // Action Buttons — use file_url from backend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Open/Read — opens the backend file_url in browser
                    SizedBox(
                      width: double.infinity,
                      height: ResourceUiConstants.primaryButtonHeight,
                      child: ElevatedButton(
                        onPressed: res.fileUrl != null
                            ? () => _openInBrowser(context, res.fileUrl!)
                            : null,
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

                    // Download PDF — launches file_url for download
                    SizedBox(
                      width: double.infinity,
                      height: ResourceUiConstants.primaryButtonHeight,
                      child: ElevatedButton.icon(
                        onPressed: res.fileUrl != null
                            ? () => _downloadFile(context, res.fileUrl!)
                            : null,
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

            const SizedBox(height: 20),

            // Report Problem Link
            Center(
              child: TextButton.icon(
                onPressed: () => _showReportDialog(context, ref, res.id),
                icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.grey),
                label: const Text(
                  'Report a problem with this resource',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _showReportDialog(
    BuildContext context,
    WidgetRef ref,
    int resourceId,
  ) async {
    String selectedReason = 'broken_file';
    final otherController = TextEditingController();
    final reasons = [
      ('broken_file', 'Broken or unreadable file'),
      ('wrong_file', 'Wrong file content'),
      ('incorrect_category', 'Incorrect category'),
      ('poor_quality', 'Poor scan or audio quality'),
      ('other', 'Other issue'),
    ];

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              title: const Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Report Resource',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why are you reporting this resource?',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ...reasons.map((r) => RadioListTile<String>(
                          value: r.$1,
                          groupValue: selectedReason,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(r.$2,
                              style: const TextStyle(fontSize: 14)),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => selectedReason = val);
                            }
                          },
                        )),
                    if (selectedReason == 'other') ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: otherController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Describe the issue...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogCtx).pop(true),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted == true && context.mounted) {
      try {
        final ds = ref.read(resourceRemoteDatasourceProvider);
        await ds.reportResource(
          resourceId: resourceId,
          reason: selectedReason,
          otherText: otherController.text.trim().isNotEmpty
              ? otherController.text.trim()
              : null,
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Report submitted successfully. Thank you for your feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit report: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _reasonLabel(String code) {
    switch (code) {
      case 'premium_required':
        return 'Premium Required';
      case 'device_mismatch':
        return 'Device Mismatch';
      case 'reverification_overdue':
        return 'Re-verification Needed';
      default:
        return code.replaceAll('_', ' ').toUpperCase();
    }
  }
}
