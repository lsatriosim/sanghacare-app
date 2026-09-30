// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_action_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TicketActions)
final ticketActionsProvider = TicketActionsProvider._();

final class TicketActionsProvider
    extends $NotifierProvider<TicketActions, void> {
  TicketActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'ticketActionsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$ticketActionsHash();

  @$internal
  @override
  TicketActions create() => TicketActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$ticketActionsHash() => r'ed1b8e6206b664a73373c8a95480ecab2ce7b541';

abstract class _$TicketActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
