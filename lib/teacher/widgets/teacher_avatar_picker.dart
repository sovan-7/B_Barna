import 'dart:typed_data';

import 'package:bbarna/resources/app_colors.dart';
import 'package:flutter/material.dart';

/// Circular photo picker shared by Add/Edit Teacher: shows a freshly-picked
/// [selectedImageBytes] if present, else falls back to [existingImageUrl]
/// (Edit only — Add has none), else a placeholder person icon.
class TeacherAvatarPicker extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final String? existingImageUrl;
  final VoidCallback onTapChange;

  const TeacherAvatarPicker({
    this.selectedImageBytes,
    this.existingImageUrl,
    required this.onTapChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasNewImage = selectedImageBytes != null;
    final bool hasExistingImage = !hasNewImage && existingImageUrl != null;

    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 104,
                width: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColorsInApp.colorGrey.withValues(alpha: .12),
                  image: hasNewImage
                      ? DecorationImage(
                          image: MemoryImage(selectedImageBytes!),
                          fit: BoxFit.cover,
                        )
                      : hasExistingImage
                          ? DecorationImage(
                              image: NetworkImage(existingImageUrl!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            )
                          : null,
                ),
                alignment: Alignment.center,
                child: (!hasNewImage && !hasExistingImage)
                    ? Icon(Icons.person,
                        size: 48,
                        color: AppColorsInApp.colorGrey.withValues(alpha: .6))
                    : null,
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onTapChange,
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColorsInApp.colorSecondary,
                      border: Border.all(
                          color: AppColorsInApp.colorWhite, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 16, color: AppColorsInApp.colorWhite),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasNewImage
                ? "Photo selected — tap to change"
                : hasExistingImage
                    ? "Tap the camera to change the photo"
                    : "Upload a photo",
            style: TextStyle(
                fontSize: 12,
                color: AppColorsInApp.colorGrey.withValues(alpha: .9)),
          ),
          const SizedBox(height: 2),
          Text(
            "JPG or PNG, up to 5MB",
            style: TextStyle(
                fontSize: 11,
                color: AppColorsInApp.colorGrey.withValues(alpha: .7)),
          ),
        ],
      ),
    );
  }
}
