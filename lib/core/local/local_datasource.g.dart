// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localDataSource)
final localDataSourceProvider = LocalDataSourceProvider._();

final class LocalDataSourceProvider
    extends
        $FunctionalProvider<LocalDataSource, LocalDataSource, LocalDataSource>
    with $Provider<LocalDataSource> {
  LocalDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDataSourceHash();

  @$internal
  @override
  $ProviderElement<LocalDataSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalDataSource create(Ref ref) {
    return localDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDataSource>(value),
    );
  }
}

String _$localDataSourceHash() => r'746ace161027ba3c2e2652e261e1c65522817f5a';
