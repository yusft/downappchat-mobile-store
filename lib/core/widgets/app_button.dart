import 'package:flutter/material.dart';
import 'package:downapp/app/theme/app_colors.dart';

/// Yeniden kullanılabilir buton bileşeni
/// [AppButtonType] ile farklı stiller desteklenir.
enum AppButtonType { primary, secondary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;
  final double borderRadius;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height = 52,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = switch (type) {
      AppButtonType.primary => _buildElevatedButton(theme),
      AppButtonType.secondary => _buildSecondaryButton(theme),
      AppButtonType.outlined => _buildOutlinedButton(theme),
      AppButtonType.text => _buildTextButton(theme),
      AppButtonType.danger => _buildDangerButton(theme),
    };

    if (isFullWidth) {
      button = SizedBox(width: double.infinity, height: height, child: button);
    }

    return button;
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: type == AppButtonType.outlined || type == AppButtonType.text
              ? theme.colorScheme.primary
              : Colors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  Widget _buildElevatedButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(theme),
    );
  }

  Widget _buildSecondaryButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(theme),
    );
  }

  Widget _buildOutlinedButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(theme),
    );
  }

  Widget _buildTextButton(ThemeData theme) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      child: _buildChild(theme),
    );
  }

  Widget _buildDangerButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      child: _buildChild(theme),
    );
  }
}
