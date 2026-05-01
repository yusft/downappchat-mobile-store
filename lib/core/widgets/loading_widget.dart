import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:downapp/app/theme/app_colors.dart';

/// Yükleme durumu widget'ı — Shimmer efektli
class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const LoadingWidget({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkCard
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkBorder
          : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Kart şeklinde yükleme shimmer'ı
  static Widget card({double height = 120}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LoadingWidget(
        width: double.infinity,
        height: height,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  /// Liste elemanı shimmer'ı
  static Widget listTile() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const LoadingWidget(
            width: 48,
            height: 48,
            borderRadius: BorderRadius.all(Radius.circular(24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoadingWidget(
                  width: double.infinity,
                  height: 14,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                LoadingWidget(
                  width: 150,
                  height: 12,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Grid uygulama kartı shimmer'ı
  static Widget appCard() {
    return Column(
      children: [
        const LoadingWidget(
          width: 64,
          height: 64,
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
        const SizedBox(height: 8),
        LoadingWidget(
          width: 80,
          height: 12,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 4),
        LoadingWidget(
          width: 50,
          height: 10,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  /// Tam sayfa yükleme göstergesi
  static Widget fullScreen() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
