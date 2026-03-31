// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentCacheBoxHash() => r'2b6ec628713c1502375385e61bcbafda8614379d';

/// See also [documentCacheBox].
@ProviderFor(documentCacheBox)
final documentCacheBoxProvider = AutoDisposeFutureProvider<Box<Map>>.internal(
  documentCacheBox,
  name: r'documentCacheBoxProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentCacheBoxHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DocumentCacheBoxRef = AutoDisposeFutureProviderRef<Box<Map>>;
String _$documentByIdHash() => r'1a567aad1662f87f097411391c06f794779b4e81';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [documentById].
@ProviderFor(documentById)
const documentByIdProvider = DocumentByIdFamily();

/// See also [documentById].
class DocumentByIdFamily extends Family<AsyncValue<DocumentModel?>> {
  /// See also [documentById].
  const DocumentByIdFamily();

  /// See also [documentById].
  DocumentByIdProvider call(
    String id,
  ) {
    return DocumentByIdProvider(
      id,
    );
  }

  @override
  DocumentByIdProvider getProviderOverride(
    covariant DocumentByIdProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'documentByIdProvider';
}

/// See also [documentById].
class DocumentByIdProvider extends AutoDisposeFutureProvider<DocumentModel?> {
  /// See also [documentById].
  DocumentByIdProvider(
    String id,
  ) : this._internal(
          (ref) => documentById(
            ref as DocumentByIdRef,
            id,
          ),
          from: documentByIdProvider,
          name: r'documentByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$documentByIdHash,
          dependencies: DocumentByIdFamily._dependencies,
          allTransitiveDependencies:
              DocumentByIdFamily._allTransitiveDependencies,
          id: id,
        );

  DocumentByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<DocumentModel?> Function(DocumentByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentByIdProvider._internal(
        (ref) => create(ref as DocumentByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<DocumentModel?> createElement() {
    return _DocumentByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DocumentByIdRef on AutoDisposeFutureProviderRef<DocumentModel?> {
  /// The parameter `id` of this provider.
  String get id;
}

class _DocumentByIdProviderElement
    extends AutoDisposeFutureProviderElement<DocumentModel?>
    with DocumentByIdRef {
  _DocumentByIdProviderElement(super.provider);

  @override
  String get id => (origin as DocumentByIdProvider).id;
}

String _$documentsNotifierHash() => r'780ce39818bf7e727c3a496850b6ff326bf2e117';

/// See also [DocumentsNotifier].
@ProviderFor(DocumentsNotifier)
final documentsNotifierProvider =
    AutoDisposeNotifierProvider<DocumentsNotifier, DocumentsState>.internal(
  DocumentsNotifier.new,
  name: r'documentsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$documentsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DocumentsNotifier = AutoDisposeNotifier<DocumentsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
