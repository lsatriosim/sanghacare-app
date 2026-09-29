// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ticketRepository)
final ticketRepositoryProvider = TicketRepositoryProvider._();

final class TicketRepositoryProvider extends $FunctionalProvider<
    TicketRepository,
    TicketRepository,
    TicketRepository> with $Provider<TicketRepository> {
  TicketRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'ticketRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ticketRepositoryHash();

  @$internal
  @override
  $ProviderElement<TicketRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TicketRepository create(Ref ref) {
    return ticketRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TicketRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TicketRepository>(value),
    );
  }
}

String _$ticketRepositoryHash() => r'de00fe79f5ad331fb53cf1549f65d6dbadf29e69';

/// Open tickets (pending + in_progress), kept live via Supabase Realtime.
///
/// `.stream()` only fires on raw table changes (no joins), so on every
/// event we just re-run the joined fetch. For a table this size that's
/// perfectly fine and far simpler than hand-rolling merge logic.

@ProviderFor(OpenTickets)
final openTicketsProvider = OpenTicketsProvider._();

/// Open tickets (pending + in_progress), kept live via Supabase Realtime.
///
/// `.stream()` only fires on raw table changes (no joins), so on every
/// event we just re-run the joined fetch. For a table this size that's
/// perfectly fine and far simpler than hand-rolling merge logic.
final class OpenTicketsProvider
    extends $AsyncNotifierProvider<OpenTickets, List<Ticket>> {
  /// Open tickets (pending + in_progress), kept live via Supabase Realtime.
  ///
  /// `.stream()` only fires on raw table changes (no joins), so on every
  /// event we just re-run the joined fetch. For a table this size that's
  /// perfectly fine and far simpler than hand-rolling merge logic.
  OpenTicketsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'openTicketsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$openTicketsHash();

  @$internal
  @override
  OpenTickets create() => OpenTickets();
}

String _$openTicketsHash() => r'880a81214dc2fa33b402805f3c617deb169af6c1';

/// Open tickets (pending + in_progress), kept live via Supabase Realtime.
///
/// `.stream()` only fires on raw table changes (no joins), so on every
/// event we just re-run the joined fetch. For a table this size that's
/// perfectly fine and far simpler than hand-rolling merge logic.

abstract class _$OpenTickets extends $AsyncNotifier<List<Ticket>> {
  FutureOr<List<Ticket>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Ticket>>, List<Ticket>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Ticket>>, List<Ticket>>,
        AsyncValue<List<Ticket>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CompletedTickets)
final completedTicketsProvider = CompletedTicketsProvider._();

final class CompletedTicketsProvider
    extends $AsyncNotifierProvider<CompletedTickets, List<Ticket>> {
  CompletedTicketsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'completedTicketsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$completedTicketsHash();

  @$internal
  @override
  CompletedTickets create() => CompletedTickets();
}

String _$completedTicketsHash() => r'6b48319cd9ac2ef20c7cb9f75554ee613c3cc01c';

abstract class _$CompletedTickets extends $AsyncNotifier<List<Ticket>> {
  FutureOr<List<Ticket>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Ticket>>, List<Ticket>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Ticket>>, List<Ticket>>,
        AsyncValue<List<Ticket>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Internal — just a heartbeat that fires on any row change in `tickets`.

@ProviderFor(_ticketChanges)
final _ticketChangesProvider = _TicketChangesProvider._();

/// Internal — just a heartbeat that fires on any row change in `tickets`.

final class _TicketChangesProvider extends $FunctionalProvider<
        AsyncValue<List<Map<String, dynamic>>>,
        List<Map<String, dynamic>>,
        Stream<List<Map<String, dynamic>>>>
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $StreamProvider<List<Map<String, dynamic>>> {
  /// Internal — just a heartbeat that fires on any row change in `tickets`.
  _TicketChangesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'_ticketChangesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$_ticketChangesHash();

  @$internal
  @override
  $StreamProviderElement<List<Map<String, dynamic>>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Map<String, dynamic>>> create(Ref ref) {
    return _ticketChanges(ref);
  }
}

String _$_ticketChangesHash() => r'e419b178d36ff468c8db3ec6024a2ac35f127c89';
