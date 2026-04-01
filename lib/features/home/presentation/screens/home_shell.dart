import 'package:docusense/shared/widgets/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/connectivity_service.dart';

class HomeShell extends StatelessWidget {
  final Widget child;

  const HomeShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', route: AppRoutes.home),
    _TabItem(icon: Icons.folder_outlined, activeIcon: Icons.folder_rounded, label: 'Docs', route: AppRoutes.documents),
    _TabItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Search', route: AppRoutes.search),
    _TabItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile', route: AppRoutes.profile),
  ];

  int _activeIndex(String location) {
    if (location.startsWith(AppRoutes.documents)) return 1;
    if (location.startsWith(AppRoutes.search)) return 2;
    if (location.startsWith(AppRoutes.profile)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final activeIndex = _activeIndex(location);

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: Stack(
        children: [
          child,
          Positioned(
            top: 0, left: 0, right: 0,
            child: OfflineBanner(),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        activeIndex: activeIndex,
        tabs: _tabs,
        onTap: (i) => context.go(_tabs[i].route),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int activeIndex;
  final List<_TabItem> tabs;
  final void Function(int) onTap;

  const _BottomNav({
    required this.activeIndex,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.void2,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(tabs.length, (i) {
              final isActive = i == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: AppConstants.microDuration,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.1 : 1.0,
                          duration: AppConstants.microDuration,
                          child: Icon(
                            isActive ? tabs[i].activeIcon : tabs[i].icon,
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textTertiary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: AppConstants.microDuration,
                          style: AppTextStyles.monoSM.copyWith(
                            fontSize: 9,
                            color: isActive
                                ? AppColors.accent
                                : AppColors.textTertiary,
                            fontWeight: isActive
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          child: Text(tabs[i].label.toUpperCase()),
                        ),
                        // Active indicator dot
                        AnimatedContainer(
                          duration: AppConstants.microDuration,
                          margin: const EdgeInsets.only(top: 4),
                          width: isActive ? 4 : 0,
                          height: isActive ? 4 : 0,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    ).animate().slideY(
          begin: 1,
          end: 0,
          delay: 200.ms,
          duration: 500.ms,
          curve: const Cubic(0.16, 1, 0.3, 1),
        );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
