import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:downapp/app/theme/app_colors.dart';
import 'package:downapp/app/router.dart';
import 'package:downapp/features/auth/presentation/providers/auth_provider.dart';
import 'package:downapp/features/chat/presentation/providers/chat_provider.dart';

/// Ana kabuk sayfası — Alt navigasyon çubuğu ile
class MainShellPage extends ConsumerWidget {
  final Widget child;

  const MainShellPage({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context, bool isDeveloper) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == AppRoutes.home) return 0;
    if (location == AppRoutes.chatList) return 1;
    if (location == AppRoutes.myProfile) return 2;
    if (isDeveloper && location == AppRoutes.developerPanel) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isDeveloper = currentUser?.isDeveloper ?? false;
    final selectedIndex = _calculateSelectedIndex(context, isDeveloper);
    final unreadCount = ref.watch(totalUnreadCountProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Keşfet',
                  isSelected: selectedIndex == 0,
                  onTap: () => context.go(AppRoutes.home),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  activeIcon: Icons.chat_bubble_rounded,
                  label: 'Mesajlar',
                  isSelected: selectedIndex == 1,
                  onTap: () => context.go(AppRoutes.chatList),
                  badgeCount: unreadCount,
                ),
                 _NavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  isSelected: selectedIndex == 2,
                  onTap: () => context.go(AppRoutes.myProfile),
                ),
                if (isDeveloper)
                  _NavItem(
                    icon: Icons.dashboard_customize_outlined,
                    activeIcon: Icons.dashboard_customize_rounded,
                    label: 'Panel',
                    isSelected: selectedIndex == 3,
                    onTap: () => context.go(AppRoutes.developerPanel),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tekil navigasyon öğesi
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 26,
                  color: isSelected
                      ? AppColors.primary
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 14),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primary
                    : Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
