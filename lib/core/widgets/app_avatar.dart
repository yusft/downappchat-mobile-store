import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:downapp/app/theme/app_colors.dart';

/// Kullanıcı avatar widget'ı
/// Online durumu, rozet, ve placeholder desteği ile.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final bool showOnlineIndicator;
  final bool isOnline;
  final bool hasBorder;
  final Color? borderColor;
  final VoidCallback? onTap;
  final String? badge; // 'verified', 'developer', 'top_reviewer'

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.hasBorder = false,
    this.borderColor,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // Avatar
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: hasBorder
                    ? Border.all(
                        color: borderColor ?? AppColors.primary,
                        width: 2.5,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _buildPlaceholder(context),
                        errorWidget: (_, __, ___) =>
                            _buildPlaceholder(context),
                      )
                    : _buildPlaceholder(context),
              ),
            ),

            // Online indicator
            if (showOnlineIndicator)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.28,
                  height: size * 0.28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? AppColors.success : AppColors.darkTextTertiary,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                ),
              ),

            // Badge
            if (badge != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: size * 0.32,
                  height: size * 0.32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _badgeColor,
                    border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    _badgeIcon,
                    size: size * 0.18,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: AppColors.primary,
      ),
    );
  }

  Color get _badgeColor {
    return switch (badge) {
      'verified' => AppColors.verifiedBadge,
      'developer' => AppColors.developerBadge,
      'top_reviewer' => AppColors.topReviewerBadge,
      _ => AppColors.primary,
    };
  }

  IconData get _badgeIcon {
    return switch (badge) {
      'verified' => Icons.verified,
      'developer' => Icons.code,
      'top_reviewer' => Icons.star,
      _ => Icons.check,
    };
  }
}
