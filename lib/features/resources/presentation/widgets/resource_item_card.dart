import 'package:flutter/material.dart';
import '../../../../core/widgets/category_icons.dart';
import '../../domain/entities/resource_item.dart';
import '../constants/resource_ui_constants.dart';

class ResourceItemCard extends StatelessWidget {
  final ResourceItem resource;
  final VoidCallback onTap;
  final VoidCallback? onDownload;
  final bool isDownloading;
  final double downloadProgress;
  final bool isDownloaded;

  const ResourceItemCard({
    super.key,
    required this.resource,
    required this.onTap,
    this.onDownload,
    this.isDownloading = false,
    this.downloadProgress = 0,
    this.isDownloaded = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: resource.locked
              ? const Color(0xFFFAFAFA)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: resource.locked
                ? const Color(0xFFE5E7EB)
                : ResourceUiConstants.cardBorderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(6),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const PdfIconBadge(size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resource.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: resource.locked
                          ? const Color(0xFF9CA3AF)
                          : ResourceUiConstants.textNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    resource.locked
                        ? 'Premium required'
                        : resource.formattedSize,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: resource.locked
                          ? const Color(0xFFD97706)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            _buildTrailingIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    // Locked state
    if (resource.locked) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.lock_rounded,
          color: Color(0xFFD97706),
          size: 20,
        ),
      );
    }

    // Downloaded state — show green checkmark
    if (isDownloaded) {
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF16A34A),
          size: 26,
        ),
      );
    }

    // Downloading state — show circular progress on top of download icon
    if (isDownloading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              value: downloadProgress > 0 ? downloadProgress : null,
              strokeWidth: 2.5,
              color: ResourceUiConstants.textNavy,
            ),
          ),
        ),
      );
    }

    // Default: download icon
    return IconButton(
      onPressed: onDownload,
      icon: const Icon(
        Icons.file_download_outlined,
        color: ResourceUiConstants.textNavy,
        size: 26,
      ),
    );
  }
}
