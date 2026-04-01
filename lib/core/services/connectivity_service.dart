import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:docusense/core/constants/app_constants.dart';
import 'package:docusense/shared/providers/connectivity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../theme/app_theme.dart';

part 'connectivity_service.g.dart';

// ── Connectivity stream ───────────────────────────────────────────────────────

@riverpod
Stream<bool> connectivityStream(ConnectivityStreamRef ref) {
  return Connectivity()
      .onConnectivityChanged
      .map((results) => !results.contains(ConnectivityResult.none));
}

@riverpod
Future<bool> isOnline(IsOnlineRef ref) async {
  final results = await Connectivity().checkConnectivity();
  return !results.contains(ConnectivityResult.none);
}

// ── Offline banner widget ─────────────────────────────────────────────────────
//
// Wrap any screen body with:
//   Stack(children: [
//     YourContent(),
//     const Positioned(top: 0, left: 0, right: 0, child: OfflineBanner()),
//   ])

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connStream = ref.watch(connectivityStreamProvider);

    return connStream.when(
      data: (isConnected) => AnimatedSlide(
        duration: AppConstants.standardDuration,
        offset: isConnected ? const Offset(0, -1) : Offset.zero,
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          duration: AppConstants.standardDuration,
          opacity: isConnected ? 0 : 1,
          child: _BannerContent(),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(
      16,
      MediaQuery.of(context).padding.top + 6,
      16,
      8,
    ),
    color: AppColors.amber,
    child: Row(children: [
      const Icon(Icons.wifi_off_rounded, size: 14, color: AppColors.void0),
      const SizedBox(width: 8),
      Text(
        'No internet — showing cached data',
        style: AppTextStyles.bodySM.copyWith(
          color: AppColors.void0,
          fontWeight: FontWeight.w600,
        ),
      ),
    ]),
  );
}

// ── Network-aware async action ─────────────────────────────────────────────────
//
// Wraps an async call with offline detection:
//   await withConnectivity(context, () => myApiCall());

Future<T?> withConnectivity<T>(
  BuildContext context,
  Future<T> Function() action, {
  String offlineMessage = 'No internet connection',
}) async {
  final results = await Connectivity().checkConnectivity();
  final isOffline = results.contains(ConnectivityResult.none);

  if (isOffline) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surface1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.wire, width: 0.5),
          ),
          content: Row(children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppColors.amber, size: 16),
            const SizedBox(width: 8),
            Text(offlineMessage,
                style: AppTextStyles.bodyMD
                    .copyWith(color: AppColors.ink0)),
          ]),
          duration: const Duration(seconds: 3),
        ),
      );
    }
    return null;
  }

  return await action();
}
