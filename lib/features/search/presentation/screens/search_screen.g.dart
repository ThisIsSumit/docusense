// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchNotifierHash() => r'f6417aadcb83ea00d382c0c26ff0bfec89259507';

/// See also [SearchNotifier].
@ProviderFor(SearchNotifier)
final searchNotifierProvider = AutoDisposeNotifierProvider<
    SearchNotifier,
    ({
      String query,
      List<DocumentModel> results,
      bool isSearching,
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
      List<DocumentModel> results,
      bool isSearching,
      List<String> recentQueries
    })>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
