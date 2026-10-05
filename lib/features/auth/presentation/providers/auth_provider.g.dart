// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'b9113114874a44d746f3b71d30ba28ae369a441f';

/// Holds the currently signed-in user (or null). The router watches this
/// to decide whether to show the login screen or the ticket list.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Holds the currently signed-in user (or null). The router watches this
/// to decide whether to show the login screen or the ticket list.
final class AuthControllerProvider
    extends $StreamNotifierProvider<AuthController, User?> {
  /// Holds the currently signed-in user (or null). The router watches this
  /// to decide whether to show the login screen or the ticket list.
  AuthControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'04f2458478c84c2ef3826039efc2e27bc096a830';

/// Holds the currently signed-in user (or null). The router watches this
/// to decide whether to show the login screen or the ticket list.

abstract class _$AuthController extends $StreamNotifier<User?> {
  Stream<User?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<User?>, User?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<User?>, User?>,
        AsyncValue<User?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
