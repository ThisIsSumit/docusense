import 'package:docusense/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../providers/auth_provider.dart';
import '../../../../core/utils/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';

part 'profile_screen.g.dart';

// ── Stats provider ────────────────────────────────────────────────────────────

@riverpod
Future<UserStats> userStats(UserStatsRef ref) async {
  return ref.read(usersRemoteDatasourceProvider).getStats();
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateNotifierProvider).valueOrNull?.user;
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.void1,
      body: RefreshIndicator(
        color: AppColors.signal,
        backgroundColor: AppColors.surface1,
        onRefresh: () async {
          ref.invalidate(userStatsProvider);
          await ref.read(authStateNotifierProvider.notifier).refreshProfile();
        },
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: AppColors.void1,
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.signalTrace,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppColors.signal.withOpacity(0.3),
                              width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            (user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : 'U')
                                .toUpperCase(),
                            style: AppTextStyles.displayMD
                                .copyWith(color: AppColors.signal),
                          ),
                        ),
                      ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            curve: const Cubic(0.34, 1.56, 0.64, 1),
                            duration: 500.ms,
                          ),
                      const SizedBox(height: 10),
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
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Live stats ─────────────────────────────────────────
                    _SectionLabel('USAGE'),
                    const SizedBox(height: 12),
                    statsAsync.when(
                      loading: () => Row(children: [
                        Expanded(child: ShimmerBox(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(10))),
                        const SizedBox(width: 12),
                        Expanded(child: ShimmerBox(width: double.infinity, height: 80, borderRadius: BorderRadius.circular(10))),
                      ]),
                      error: (e, _) => _ErrorTile(
                        message: 'Could not load stats',
                        onRetry: () => ref.invalidate(userStatsProvider),
                      ),
                      data: (stats) => Row(children: [
                        Expanded(child: _StatTile(
                          label: 'Documents',
                          value: '${stats.documentsCount}',
                          color: AppColors.signal,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _StatTile(
                          label: 'Queries',
                          value: '${stats.queriesCount}',
                          color: AppColors.amber,
                        )),
                      ]),
                    ).animate().fadeIn(delay: 200.ms),

                    // Doc status breakdown
                    statsAsync.whenData((stats) {
                      final s = stats.documentsByStatus;
                      return Column(
                        children: [
                          const SizedBox(height: 10),
                          _DocStatusRow(ready: s['READY'] ?? 0,
                              processing: s['PROCESSING'] ?? 0,
                              failed: s['FAILED'] ?? 0),
                        ],
                      );
                    }).valueOrNull ?? const SizedBox.shrink(),

                    const SizedBox(height: 28),

                    // ── Recent queries ─────────────────────────────────────
                    statsAsync.whenData((stats) {
                      if (stats.recentQueries.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('RECENT QUERIES'),
                          const SizedBox(height: 10),
                          ...stats.recentQueries.take(3).map((q) =>
                              _RecentQueryTile(query: q)),
                          const SizedBox(height: 28),
                        ],
                      );
                    }).valueOrNull ?? const SizedBox.shrink(),

                    // ── Account settings ───────────────────────────────────
                    _SectionLabel('ACCOUNT'),
                    const SizedBox(height: 10),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.person_outline_rounded,
                        label: 'Edit profile',
                        onTap: () => _showEditProfileSheet(context, ref, user?.name ?? ''),
                      ),
                      _SettingsItem(
                        icon: Icons.lock_outline_rounded,
                        label: 'Change password',
                        onTap: () => _showChangePasswordSheet(context, ref),
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: () {},
                        trailing: _Toggle(),
                      ),
                    ]).animate().fadeIn(delay: 280.ms),

                    const SizedBox(height: 20),

                    _SectionLabel('DANGER ZONE'),
                    const SizedBox(height: 10),
                    _SettingsGroup(items: [
                      _SettingsItem(
                        icon: Icons.delete_forever_outlined,
                        label: 'Delete account',
                        onTap: () => _showDeleteAccountDialog(context, ref),
                        iconColor: AppColors.red,
                        labelColor: AppColors.red,
                      ),
                    ]).animate().fadeIn(delay: 320.ms),

                    const SizedBox(height: 28),

                    // ── Sign out ───────────────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        await ref
                            .read(authStateNotifierProvider.notifier)
                            .logout();
                        if (context.mounted) context.go(AppRoutes.login);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.redTrace,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.red.withOpacity(0.25),
                              width: 0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout_rounded,
                                color: AppColors.red, size: 16),
                            const SizedBox(width: 8),
                            Text('Sign out',
                                style: AppTextStyles.headingSM
                                    .copyWith(color: AppColors.red)),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 380.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile edit sheet ────────────────────────────────────────────────────────

void _showEditProfileSheet(BuildContext ctx, WidgetRef ref, String currentName) {
  final ctrl = TextEditingController(text: currentName);
  bool saving = false;

  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx2, setState) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx2).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(top: BorderSide(color: AppColors.wire, width: 0.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32, height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.wireHot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Edit profile', style: AppTextStyles.headingSM),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Name',
                controller: ctrl,
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              GlowButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() => saving = true);
                        try {
                          await ref
                              .read(usersRemoteDatasourceProvider)
                              .updateProfile(name: ctrl.text.trim());
                          await ref
                              .read(authStateNotifierProvider.notifier)
                              .refreshProfile();
                          if (ctx2.mounted) Navigator.pop(ctx2);
                        } on ApiException catch (e) {
                          setState(() => saving = false);
                          if (ctx2.mounted) {
                            ScaffoldMessenger.of(ctx2).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                          }
                        }
                      },
                isLoading: saving,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Change password sheet ─────────────────────────────────────────────────────

void _showChangePasswordSheet(BuildContext ctx, WidgetRef ref) {
  final currentCtrl = TextEditingController();
  final newCtrl = TextEditingController();
  bool saving = false;
  String? error;

  showModalBottomSheet(
    context: ctx,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx2, setState) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx2).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface0,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            border: Border(top: BorderSide(color: AppColors.wire, width: 0.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32, height: 3,
                  decoration: BoxDecoration(
                    color: AppColors.wireHot,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Change password', style: AppTextStyles.headingSM),
              const SizedBox(height: 16),
              if (error != null) ...[
                ErrorBanner(message: error!),
                const SizedBox(height: 12),
              ],
              AppTextField(
                label: 'Current password',
                controller: currentCtrl,
                isPassword: true,
                autofocus: true,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'New password',
                controller: newCtrl,
                isPassword: true,
                textInputAction: TextInputAction.done,
                validator: (v) =>
                    (v != null && v.length < 8) ? 'Min 8 characters' : null,
              ),
              const SizedBox(height: 20),
              GlowButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (newCtrl.text.length < 8) {
                          setState(() => error = 'New password must be at least 8 characters');
                          return;
                        }
                        setState(() { saving = true; error = null; });
                        try {
                          await ref
                              .read(authRemoteDatasourceProvider)
                              .changePassword(
                                currentPassword: currentCtrl.text,
                                newPassword: newCtrl.text,
                              );
                          if (ctx2.mounted) Navigator.pop(ctx2);
                        } on ApiException catch (e) {
                          setState(() {
                            saving = false;
                            error = e.message;
                          });
                        }
                      },
                isLoading: saving,
                child: const Text('Update password'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ── Delete account dialog ─────────────────────────────────────────────────────

void _showDeleteAccountDialog(BuildContext ctx, WidgetRef ref) {
  bool deleting = false;
  showDialog(
    context: ctx,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => StatefulBuilder(
      builder: (ctx2, setState) => AlertDialog(
        backgroundColor: AppColors.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.red.withOpacity(0.3), width: 0.5),
        ),
        title: Text('Delete account', style: AppTextStyles.headingSM),
        content: Text(
          'All your documents, chunks, and query history will be permanently '
          'deleted. This cannot be undone.',
          style: AppTextStyles.bodyMD,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx2),
            child: Text('Cancel',
                style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink1)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red, minimumSize: const Size(80, 40),
            ),
            onPressed: deleting
                ? null
                : () async {
                    setState(() => deleting = true);
                    try {
                      await ref
                          .read(usersRemoteDatasourceProvider)
                          .deleteAccount();
                      await ref
                          .read(authStateNotifierProvider.notifier)
                          .logout();
                      if (ctx2.mounted) {
                        Navigator.pop(ctx2);
                        ctx.go(AppRoutes.login);
                      }
                    } on ApiException catch (e) {
                      setState(() => deleting = false);
                      if (ctx2.mounted) {
                        ScaffoldMessenger.of(ctx2).showSnackBar(
                          SnackBar(content: Text(e.message)),
                        );
                      }
                    }
                  },
            child: deleting
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppColors.void0))
                : const Text('Delete', style: TextStyle(color: AppColors.void0)),
          ),
        ],
      ),
    ),
  );
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMD);
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface0,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.wire, width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value,
          style: AppTextStyles.displayMD.copyWith(color: color)),
      const SizedBox(height: 3),
      Text(label, style: AppTextStyles.bodySM),
    ]),
  );
}

class _DocStatusRow extends StatelessWidget {
  final int ready, processing, failed;
  const _DocStatusRow({required this.ready, required this.processing, required this.failed});

  @override
  Widget build(BuildContext context) => Row(children: [
    _StatusPill(label: '$ready ready', color: AppColors.green),
    if (processing > 0) ...[
      const SizedBox(width: 6),
      _StatusPill(label: '$processing processing', color: AppColors.amber),
    ],
    if (failed > 0) ...[
      const SizedBox(width: 6),
      _StatusPill(label: '$failed failed', color: AppColors.red),
    ],
  ]);
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(3),
      border: Border.all(color: color.withOpacity(0.25), width: 0.5),
    ),
    child: Text(label, style: AppTextStyles.monoSM.copyWith(color: color)),
  );
}

class _RecentQueryTile extends StatelessWidget {
  final RecentQuery query;
  const _RecentQueryTile({required this.query});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.surface0,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.wire, width: 0.5),
    ),
    child: Row(children: [
      const Icon(Icons.chat_bubble_outline_rounded,
          color: AppColors.ink2, size: 14),
      const SizedBox(width: 10),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(query.question, style: AppTextStyles.bodyMD.copyWith(color: AppColors.ink0),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          if (query.document != null)
            Text(query.document!.title,
                style: AppTextStyles.monoSM, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      )),
    ]),
  );
}

class _ErrorTile extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorTile({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.redTrace,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.red.withOpacity(0.2), width: 0.5),
    ),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(message, style: AppTextStyles.bodyMD.copyWith(color: AppColors.red))),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ]),
  );
}

class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface0,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.wire, width: 0.5),
    ),
    child: Column(children: items.asMap().entries.map((e) {
      final isLast = e.key == items.length - 1;
      return Container(
        decoration: BoxDecoration(
          border: isLast ? null : const Border(
              bottom: BorderSide(color: AppColors.wireDim, width: 0.5)),
        ),
        child: e.value,
      );
    }).toList()),
  );
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;
  final Color? labelColor;
  const _SettingsItem({
    required this.icon, required this.label, required this.onTap,
    this.trailing, this.iconColor, this.labelColor,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(children: [
        Icon(icon, color: iconColor ?? AppColors.ink1, size: 17),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: AppTextStyles.bodyMD.copyWith(
                color: labelColor ?? AppColors.ink0))),
        trailing ?? Icon(Icons.chevron_right_rounded,
            color: AppColors.ink3, size: 16),
      ]),
    ),
  );
}

class _Toggle extends StatefulWidget {
  @override
  State<_Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<_Toggle> {
  bool _on = true;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => _on = !_on),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 38, height: 21,
      decoration: BoxDecoration(
        color: _on ? AppColors.signal : AppColors.surface3,
        borderRadius: BorderRadius.circular(11),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 150),
        alignment: _on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(2),
          width: 17, height: 17,
          decoration: const BoxDecoration(
            color: Colors.white, shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}
