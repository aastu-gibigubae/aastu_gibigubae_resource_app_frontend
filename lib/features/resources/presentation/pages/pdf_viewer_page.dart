import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/resource_item.dart';
import '../../providers/resource_providers.dart';
import '../widgets/download_success_dialog.dart';

/// ================================================================
/// PDF VIEWER PAGE
///
/// Renders a real PDF using flutter_pdfview (native PDFium on Android,
/// WKWebView on iOS). Supports two sources:
///   1. Local file path (already downloaded to app sandbox)
///   2. Remote URL  → streamed via flutter_cache_manager, then rendered
///
/// The "Save to app" download button saves the file into the sandbox
/// via ResourceDownloadService (no external file access).
/// ================================================================

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
  // ── PDF state ──────────────────────────────────────────────────
  String? _localPath;       // path to the resolved PDF file
  bool _isReady = false;    // true once PDFView is ready to render
  bool _isLoading = true;   // true while resolving path
  String? _loadError;       // non-null if resolution/render failed

  // ── Page tracking ──────────────────────────────────────────────
  int _currentPage = 0;
  int _totalPages = 0;
  PDFViewController? _pdfController;

  // ── Download state ─────────────────────────────────────────────
  bool _isDownloading = false;
  double _downloadProgress = 0;

  @override
  void initState() {
    super.initState();
    _resolveSource();
  }

  // ── Source resolution ──────────────────────────────────────────

  /// Checks if a local file is a real PDF (not a tiny fallback stub).
  /// Real PDFs are typically at least a few KB.
  Future<bool> _isValidPdf(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;
      final size = await file.length();
      // A real PDF is at least ~500 bytes; our fallback stubs are ~50 bytes
      if (size < 500) return false;
      // Check for PDF magic bytes
      final bytes = await file.openRead(0, 5).expand((b) => b).toList();
      return bytes.length >= 4 &&
          bytes[0] == 0x25 && // %
          bytes[1] == 0x50 && // P
          bytes[2] == 0x44 && // D
          bytes[3] == 0x46;   // F
    } catch (_) {
      return false;
    }
  }

  /// Resolves the PDF to a local file path:
  ///   1. If already downloaded in sandbox AND is a valid PDF → use that.
  ///   2. If remote URL → cache/stream with flutter_cache_manager.
  ///   3. If neither works → show error.
  Future<void> _resolveSource() async {
    final res = widget.resource;

    // Check sandbox first
    if (res != null) {
      final service = ref.read(resourceDownloadServiceProvider);
      final localPath = await service.getLocalFilePath(res.id);
      if (localPath != null && await _isValidPdf(localPath)) {
        if (mounted) {
          setState(() {
            _localPath = localPath;
            _isLoading = false;
          });
        }
        return;
      }
    }

    // Use remote URL
    final url = res?.fileUrl ?? widget.fileUrl;
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      if (mounted) {
        setState(() {
          _loadError = 'No PDF source available for this resource.\n'
              'The file may not have been uploaded yet.';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      // flutter_cache_manager downloads + caches the file.
      final file = await DefaultCacheManager().getSingleFile(url);
      if (await _isValidPdf(file.path)) {
        if (mounted) {
          setState(() {
            _localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadError = 'The downloaded file is not a valid PDF.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = ErrorMapper.fromDocumentError(e).message;
          _isLoading = false;
        });
      }
    }
  }

  // ── In-app download (sandbox save) ────────────────────────────

  Future<void> _downloadToApp() async {
    final res = widget.resource;
    if (res == null) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final service = ref.read(resourceDownloadServiceProvider);
      await service.downloadResource(
        res,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );
      ref.invalidate(isResourceDownloadedProvider(res.id));
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
        setState(() {
          _isDownloading = false;
          _downloadProgress = 0;
        });
      }
    }
  }

  // ── Navigation helpers ─────────────────────────────────────────

  Future<void> _goToPage(int page) async {
    await _pdfController?.setPage(page);
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final res = widget.resource;
    final effectiveTitle = res?.title ?? widget.title;
    final effectiveCourseName =
        (res?.courseName.isNotEmpty == true) ? res!.courseName : widget.courseName;

    final isDownloaded = res != null
        ? (ref.watch(isResourceDownloadedProvider(res.id)).valueOrNull ?? false)
        : false;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────
            _buildHeader(
              context,
              effectiveTitle: effectiveTitle,
              effectiveCourseName: effectiveCourseName,
              isDownloaded: isDownloaded,
              res: res,
            ),

            // ── Toolbar ─────────────────────────────────────────
            if (_localPath != null && _isReady)
              _buildToolbar(),

            // ── PDF Body ────────────────────────────────────────
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

  Widget _buildHeader(
    BuildContext context, {
    required String effectiveTitle,
    required String effectiveCourseName,
    required bool isDownloaded,
    required ResourceItem? res,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 6,
        8,
        14,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/home'),
              ),
              const SizedBox(width: 4),
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
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      effectiveTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              // Download button
              if (res != null && !isDownloaded)
                _isDownloading
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              value: _downloadProgress > 0 ? _downloadProgress : null,
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                          if (_downloadProgress > 0)
                            Text(
                              '${(_downloadProgress * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
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

              // Saved indicator
              if (isDownloaded)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.offline_pin_rounded,
                      color: Color(0xFF4ADE80), size: 22),
                ),
            ],
          ),

          // Storage mode pill
          Padding(
            padding: const EdgeInsets.only(left: 44, top: 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isDownloaded
                      ? const Color(0xFF16A34A).withAlpha(60)
                      : Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
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
                          ? Icons.offline_pin_outlined
                          : Icons.cloud_outlined,
                      size: 13,
                      color: isDownloaded
                          ? const Color(0xFF4ADE80)
                          : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isDownloaded
                          ? 'In-App Offline'
                          : 'Online Streaming',
                      style: TextStyle(
                        color: isDownloaded
                            ? const Color(0xFF4ADE80)
                            : Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Toolbar ───────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Container(
      height: 48,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Prev page
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 28),
            onPressed: _currentPage > 0
                ? () => _goToPage(_currentPage - 1)
                : null,
          ),

          // Page indicator
          Expanded(
            child: Center(
              child: Text(
                _totalPages > 0
                    ? 'Page ${_currentPage + 1} of $_totalPages'
                    : 'Loading...',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Next page
          IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 28),
            onPressed: (_totalPages > 0 && _currentPage < _totalPages - 1)
                ? () => _goToPage(_currentPage + 1)
                : null,
          ),
        ],
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────

  Widget _buildBody() {
    // Loading state
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Error state
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.picture_as_pdf_outlined,
                  size: 64, color: Colors.white30),
              const SizedBox(height: 20),
              const Text(
                'Could Not Load PDF',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _loadError = null;
                    _localPath = null;
                  });
                  _resolveSource();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // No path resolved
    if (_localPath == null) {
      return const Center(
        child: Text(
          'No PDF available.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    // Real PDF rendering
    return Stack(
      children: [
        PDFView(
          filePath: _localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          pageSnap: true,
          fitPolicy: FitPolicy.BOTH,
          onRender: (pages) {
            if (mounted) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            }
          },
          onViewCreated: (controller) {
            _pdfController = controller;
            // Safety timeout: if onRender never fires within 8s,
            // hide the overlay and show whatever is rendered (or error).
            Future.delayed(const Duration(seconds: 8), () {
              if (mounted && !_isReady) {
                setState(() {
                  _isReady = true;
                  if (_totalPages == 0) {
                    _loadError = 'PDF could not be rendered. '
                        'The file may be corrupted or not a valid PDF.';
                  }
                });
              }
            });
          },
          onPageChanged: (page, total) {
            if (mounted) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? _totalPages;
              });
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() {
                _loadError = ErrorMapper.fromPdfRenderError(error).message;
                _isReady = true; // Remove overlay so error view is shown
              });
            }
          },
          onPageError: (page, error) {
            debugPrint('[PdfViewerPage] page $page error: $error');
          },
        ),

        // Initial render overlay — shown while PDFView initialises
        if (!_isReady)
          Container(
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Preparing document...',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
