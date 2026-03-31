import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateNotifierProvider).valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.void1,
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accentFaint,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3),
                            width: 1),
                      ),
                      child: Center(
                        child: Text(
                          (user?.name.isNotEmpty == true
                                  ? user!.name[0]
                                  : 'U')
                              .toUpperCase(),
                          style: AppTextStyles.displayMD
                              .copyWith(color: AppColors.accent),
                        ),
                      ),
                    ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          curve: const Cubic(0.34, 1.56, 0.64, 1),
                          duration: 500.ms,
                        ),
                    const SizedBox(height: 12),
                    Text(user?.name ?? 'User',
                            style: AppTextStyles.headingMD)
                        .animate()
                        .fadeIn(delay: 100.ms),
                    Text(user?.email ?? '',
                            style: AppTextStyles.bodyMD)
                        .animate()
                        .fadeIn(delay: 150.ms),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  _SectionLabel('Usage'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Documents',
                          value: '${user?.documentsCount ?? 0}',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(
                          label: 'Queries',
                          value: '${user?.queriesCount ?? 0}',
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 28),

                  _SectionLabel('Account'),
                  const SizedBox(height: 12),
                  _SettingsGroup(items: [
                    _SettingsItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Edit Profile',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () {},
                      trailing: _Toggle(),
                    ),
                    _SettingsItem(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: 20),

                  _SectionLabel('Storage'),
                  const SizedBox(height: 12),
                  _SettingsGroup(items: [
                    _SettingsItem(
                      icon: Icons.storage_rounded,
                      label: 'Cache Size',
                      onTap: () {},
                      trailing: Text('2.4 MB',
                          style: AppTextStyles.monoSM),
                    ),
                    _SettingsItem(
                      icon: Icons.delete_outline_rounded,
                      label: 'Clear Cache',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 20),

                  _SectionLabel('About'),
                  const SizedBox(height: 12),
                  _SettingsGroup(items: [
                    _SettingsItem(
                      icon: Icons.info_outline_rounded,
                      label: 'Version',
                      onTap: () {},
                      trailing: Text('1.0.0',
                          style: AppTextStyles.monoSM),
                    ),
                    _SettingsItem(
                      icon: Icons.shield_outlined,
                      label: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _SettingsItem(
                      icon: Icons.article_outlined,
                      label: 'Terms of Service',
                      onTap: () {},
                    ),
                  ]).animate().fadeIn(delay: 350.ms),

                  const SizedBox(height: 28),

                  // Sign out
                  GestureDetector(
                    onTap: () async {
                      await ref
                          .read(authStateNotifierProvider.notifier)
                          .logout();
                      if (context.mounted) context.go(AppRoutes.login);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Text('Sign Out',
                              style: AppTextStyles.headingSM
                                  .copyWith(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.labelMD,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.displayMD.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySM),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface0,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Container(
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom:
                          BorderSide(color: AppColors.border, width: 1)),
            ),
            child: e.value,
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 18),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: AppTextStyles.bodyMD
                  .copyWith(color: AppColors.textPrimary)),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatefulWidget {
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _value = !_value),
      child: AnimatedContainer(
        duration: AppConstants.microDuration,
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          color: _value ? AppColors.accent : AppColors.surface3,
          borderRadius: BorderRadius.circular(11),
        ),
        child: AnimatedAlign(
          duration: AppConstants.microDuration,
          alignment:
              _value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(2),
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
