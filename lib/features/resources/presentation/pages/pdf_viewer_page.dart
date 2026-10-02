import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../widgets/download_success_dialog.dart';

class PdfViewerPage extends ConsumerStatefulWidget {
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
  ConsumerState<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends ConsumerState<PdfViewerPage> {
  int _currentPage = 1;
  final int _totalPages = 40;
  final TransformationController _transformController =
      TransformationController();
  double _zoomLevel = 1.0;
  bool _isDownloading = false;

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + 0.25).clamp(0.8, 3.0);
      _transformController.value =
          Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, 1.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - 0.25).clamp(0.8, 3.0);
      _transformController.value =
          Matrix4.diagonal3Values(_zoomLevel, _zoomLevel, 1.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _transformController.value = Matrix4.identity();
    });
  }

  Future<void> _downloadToApp() async {
    final res = widget.resource;
    if (res == null) return;

    setState(() => _isDownloading = true);
    try {
      final service = ref.read(resourceDownloadServiceProvider);
      await service.downloadResource(res);
      ref.invalidate(isResourceDownloadedProvider(res.id));
      if (mounted) {
        await showDownloadSuccessDialog(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open external viewer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = widget.resource;
    final effectiveTitle = res?.title ?? widget.title;
    final effectiveCourseName =
        res?.courseName.isNotEmpty == true ? res!.courseName : widget.courseName;
    final effectiveFileUrl = res?.fileUrl ?? widget.fileUrl;

    final isDownloaded = res != null
        ? (ref.watch(isResourceDownloadedProvider(res.id)).valueOrNull ?? false)
        : false;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Navy Curved Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + 10,
                16,
                20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                fontSize: 15,
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
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Download to app button if not yet downloaded
                      if (!isDownloaded && res != null)
                        _isDownloading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(
                                  Icons.download_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                tooltip: 'Save to in-app storage',
                                onPressed: _downloadToApp,
                              ),
                      // External viewer button
                      if (effectiveFileUrl != null &&
                          effectiveFileUrl.isNotEmpty)
                        IconButton(
                          icon: const Icon(
                            Icons.open_in_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Open in system app',
                          onPressed: () => _openExternal(effectiveFileUrl),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Storage mode pill (In-App Offline vs Online Stream)
                  Padding(
                    padding: const EdgeInsets.only(left: 48),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDownloaded
                            ? const Color(0xFF16A34A).withAlpha(50)
                            : Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDownloaded
                              ? const Color(0xFF22C55E)
                              : Colors.white30,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDownloaded
                                ? Icons.offline_pin_rounded
                                : Icons.cloud_outlined,
                            size: 14,
                            color: isDownloaded
                                ? const Color(0xFF4ADE80)
                                : Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDownloaded
                                ? 'In-App Storage (Offline Access)'
                                : 'Online Reader Mode',
                            style: TextStyle(
                              color: isDownloaded
                                  ? const Color(0xFF4ADE80)
                                  : Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // In-app Reader Controls Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  // Page controller
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 26),
                    tooltip: 'Previous page',
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                  ),
                  Text(
                    'Page $_currentPage / $_totalPages',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 26),
                    tooltip: 'Next page',
                    onPressed: _currentPage < _totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                  ),
                  const Spacer(),
                  // Zoom Out
                  IconButton(
                    icon: const Icon(Icons.zoom_out_rounded, size: 22),
                    tooltip: 'Zoom out',
                    onPressed: _zoomOut,
                  ),
                  // Zoom Reset
                  InkWell(
                    onTap: _resetZoom,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: Text(
                        '${(_zoomLevel * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                  // Zoom In
                  IconButton(
                    icon: const Icon(Icons.zoom_in_rounded, size: 22),
                    tooltip: 'Zoom in',
                    onPressed: _zoomIn,
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // In-App Document Canvas matching image copy 17.png with Interactive Viewer
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Document Content Representation
                        Positioned.fill(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(28, 36, 36, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Page Header
                                Container(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Color(0xFFF1F5F9),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        effectiveCourseName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF94A3B8),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      Text(
                                        'P. $_currentPage',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Document Title in page
                                Text(
                                  '$effectiveTitle — Part $_currentPage',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Reading Layout Simulation matching UI design image copy 17.png
                                _buildDocLine(width: 90, height: 16),
                                const SizedBox(height: 20),
                                _buildDocLine(width: 150, height: 16),
                                const SizedBox(height: 20),
                                _buildDocLine(width: 200, height: 16),
                                const SizedBox(height: 20),
                                _buildDocLine(width: 260, height: 16),
                                const SizedBox(height: 20),
                                _buildDocLine(width: 280, height: 16),
                                const SizedBox(height: 20),
                                _buildDocLine(width: 300, height: 16),

                                const SizedBox(height: 36),

                                // Paragraph body lines
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
            ),
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
