// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchNotifierHash() => r'acdb7cd8bc63f381de8a39efb4f6596670057082';

/// See also [SearchNotifier].
@ProviderFor(SearchNotifier)
final searchNotifierProvider = AutoDisposeNotifierProvider<
    SearchNotifier,
    ({
      String query,
      List<SearchResult> results,
      bool isSearching,
      String? error,
      List<String> recentQueries
    })>.internal(
  SearchNotifier.new,
  name: r'searchNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchNotifier = AutoDisposeNotifier<
    ({
      String query,
      List<SearchResult> results,
      bool isSearching,
      String? error,
      List<String> recentQueries
    })>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
