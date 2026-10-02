import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../data/datasources/mock_resource_datasource.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../widgets/download_success_dialog.dart';

class ResourceDetailPage extends ConsumerStatefulWidget {
  final ResourceItem? resource;
  final int resourceId;

  const ResourceDetailPage({
    super.key,
    this.resource,
    this.resourceId = 0,
  });

  @override
  ConsumerState<ResourceDetailPage> createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends ConsumerState<ResourceDetailPage> {
  bool _isActionLoading = false;

  Future<void> _handleDownload(ResourceItem res) async {
    if (_isActionLoading) return;
    setState(() => _isActionLoading = true);
    try {
      final downloadService = ref.read(resourceDownloadServiceProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading resource into app storage...'),
          duration: Duration(seconds: 1),
        ),
      );
      await downloadService.downloadResource(res);
      ref.invalidate(isResourceDownloadedProvider(res.id));
      ref.invalidate(downloadedResourceIdsProvider);
      if (mounted) {
        await showDownloadSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMapper.userMessage(
                e,
                defaultMessage: 'Download failed. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  Future<void> _handleDelete(ResourceItem res) async {
    if (_isActionLoading) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Resource',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to remove this downloaded file from your device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isActionLoading = true);
    try {
      final downloadService = ref.read(resourceDownloadServiceProvider);
      await downloadService.deleteDownload(res.id);
      ref.invalidate(isResourceDownloadedProvider(res.id));
      ref.invalidate(downloadedResourceIdsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Downloaded resource deleted.'),
            duration: Duration(seconds: 2),
            backgroundColor: Color(0xFF334155),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ErrorMapper.userMessage(
                e,
                defaultMessage: 'Failed to delete download. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.resource ??
        (widget.resourceId > 0
            ? const MockResourceDatasource().getResourceById(widget.resourceId)
            : null);

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

    final courseTitle = res.courseName.isNotEmpty
        ? res.courseName
        : 'Communicative English I';
    final fileSizeStr = res.fileSizeBytes > 0
        ? '${(res.fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '2.4 MB';
    final isDownloaded =
        ref.watch(isResourceDownloadedProvider(res.id)).valueOrNull ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Navy Curved Header matching image copy 16.png
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).padding.top + 12,
                  24,
                  26,
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
                          context.go(RouteNames.browse);
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
                            courseTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            res.title,
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
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Title Section with PDF Badge matching image copy 16.png
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            courseTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Document Specifications Card matching image copy 16.png
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(6),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSpecRow(
                        icon: Icons.description_outlined,
                        label: 'File type',
                        value: 'Pdf Document',
                      ),
                      const SizedBox(height: 18),
                      _buildSpecRow(
                        icon: Icons.description_outlined,
                        label: 'File size',
                        value: fileSizeStr,
                      ),
                      const SizedBox(height: 18),
                      _buildSpecRow(
                        icon: Icons.description_outlined,
                        label: 'Format',
                        value: 'PDF Document',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Locked Warning Banner (if resource is locked)
              if (res.locked) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(RouteNames.premium),
                      icon: const Icon(Icons.star_rounded, color: Colors.white),
                      label: const Text(
                        'Upgrade to Premium Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Action Buttons matching image copy 16.png
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // Open/Read button (Navy Blue)
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push(
                              RouteNames.pdfViewer,
                              extra: res,
                            );
                          },
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text(
                            'Open/Read',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Download PDF or Delete button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isActionLoading
                              ? null
                              : (isDownloaded
                                  ? () => _handleDelete(res)
                                  : () => _handleDownload(res)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDownloaded
                                ? const Color(0xFFDC2626)
                                : AppColors.secondary,
                            disabledBackgroundColor: (isDownloaded
                                    ? const Color(0xFFDC2626)
                                    : AppColors.secondary)
                                .withAlpha(160),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isActionLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isDownloaded
                                          ? Icons.delete_outline_rounded
                                          : Icons.download_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isDownloaded ? 'Delete' : 'Download PDF',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Report problem link
              Center(
                child: TextButton.icon(
                  onPressed: () => _showReportDialog(context, res.id),
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
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFF1E3A8A),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Future<void> _showReportDialog(
    BuildContext context,
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
                    ...reasons.map((r) {
                      final isSelected = selectedReason == r.$1;
                      return InkWell(
                        onTap: () => setState(() => selectedReason = r.$1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  r.$2,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
              content: Text(
                ErrorMapper.userMessage(
                  e,
                  defaultMessage: 'Failed to submit report. Please try again later.',
                ),
              ),
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
