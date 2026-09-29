import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/ticket_repository.dart';

part 'ticket_providers.g.dart';

@riverpod
TicketRepository ticketRepository(Ref ref) {
  return TicketRepository(Supabase.instance.client);
}

/// Open tickets (pending + in_progress), kept live via Supabase Realtime.
///
/// `.stream()` only fires on raw table changes (no joins), so on every
/// event we just re-run the joined fetch. For a table this size that's
/// perfectly fine and far simpler than hand-rolling merge logic.
@riverpod
class OpenTickets extends _$OpenTickets {
  @override
  Future<List<Ticket>> build() async {
    final repo = ref.watch(ticketRepositoryProvider);

    // Re-fetch whenever the raw table changes.
    ref.listen(_ticketChangesProvider, (_, __) {
      ref.invalidateSelf();
    });

    return repo.fetchOpenTickets();
  }

  Future<void> assignToMe(int ticketId) async {
    final staffId = ref.read(authControllerProvider).value?.id;
    if (staffId == null) return;

    final repo = ref.read(ticketRepositoryProvider);

    // Optimistic update: reflect the change immediately, then let the
    // realtime listener above reconcile with the server's actual state.
    // final current = state.value ?? [];
    // state = AsyncData(
    //   current
    //       .map((t) => t.id == ticketId
    //           ? t.copyWith(status: TicketStatus.inProgress, assignedToId: staffId)
    //           : t)
    //       .toList(),
    // );

    await repo.assignToMe(ticketId, staffId);
  }

  Future<void> markResolved(int ticketId) async {
    final repo = ref.read(ticketRepositoryProvider);

    // Resolved tickets drop out of the "open" list entirely.
    final current = state.value ?? [];
    state = AsyncData(current.where((t) => t.id != ticketId).toList());

    await repo.markResolved(ticketId);
  }
}

@riverpod
class CompletedTickets extends _$CompletedTickets {
  @override
  Future<List<Ticket>> build() async {
    final repo = ref.watch(ticketRepositoryProvider);

    ref.listen(_ticketChangesProvider, (_, __) {
      ref.invalidateSelf();
    });

    return repo.fetchCompletedTickets();
  }
}

/// Internal — just a heartbeat that fires on any row change in `tickets`.
@riverpod
Stream<List<Map<String, dynamic>>> _ticketChanges(Ref ref) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchTicketsRaw();
}
