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
String _$documentByIdHash() => r'313c958a9944b4a8f635aa98255c9c5ef3040183';

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

String _$jobStatusStreamHash() => r'410a8e15d7aea8d469beaa5f3e1e46cd7e69619f';

/// See also [jobStatusStream].
@ProviderFor(jobStatusStream)
const jobStatusStreamProvider = JobStatusStreamFamily();

/// See also [jobStatusStream].
class JobStatusStreamFamily extends Family<AsyncValue<JobStatus>> {
  /// See also [jobStatusStream].
  const JobStatusStreamFamily();

  /// See also [jobStatusStream].
  JobStatusStreamProvider call(
    String jobId,
  ) {
    return JobStatusStreamProvider(
      jobId,
    );
  }

  @override
  JobStatusStreamProvider getProviderOverride(
    covariant JobStatusStreamProvider provider,
  ) {
    return call(
      provider.jobId,
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
  String? get name => r'jobStatusStreamProvider';
}

/// See also [jobStatusStream].
class JobStatusStreamProvider extends AutoDisposeStreamProvider<JobStatus> {
  /// See also [jobStatusStream].
  JobStatusStreamProvider(
    String jobId,
  ) : this._internal(
          (ref) => jobStatusStream(
            ref as JobStatusStreamRef,
            jobId,
          ),
          from: jobStatusStreamProvider,
          name: r'jobStatusStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$jobStatusStreamHash,
          dependencies: JobStatusStreamFamily._dependencies,
          allTransitiveDependencies:
              JobStatusStreamFamily._allTransitiveDependencies,
          jobId: jobId,
        );

  JobStatusStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.jobId,
  }) : super.internal();

  final String jobId;

  @override
  Override overrideWith(
    Stream<JobStatus> Function(JobStatusStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: JobStatusStreamProvider._internal(
        (ref) => create(ref as JobStatusStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        jobId: jobId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<JobStatus> createElement() {
    return _JobStatusStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is JobStatusStreamProvider && other.jobId == jobId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, jobId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin JobStatusStreamRef on AutoDisposeStreamProviderRef<JobStatus> {
  /// The parameter `jobId` of this provider.
  String get jobId;
}

class _JobStatusStreamProviderElement
    extends AutoDisposeStreamProviderElement<JobStatus>
    with JobStatusStreamRef {
  _JobStatusStreamProviderElement(super.provider);

  @override
  String get jobId => (origin as JobStatusStreamProvider).jobId;
}

String _$documentsNotifierHash() => r'f1415b363684c51ccbcc5addb5e6a01774488031';

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
