import 'package:flutter/foundation.dart';
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
    // Watch the master list instead of making a new network call
    final allTickets = await ref.watch(allTicketsStreamProvider.future);

    // Filter in-memory for pending or in_progress
    return allTickets
        .where((t) => t.status.name == 'pending' || t.status.name == 'in_progress')
        .toList();
  }

  Future<void> assignToMe(int ticketId) async {
    final staffId = ref.read(authControllerProvider).value?.id;
    if (staffId == null) return;
    
    // Perform the database mutation via repository
    await ref.read(ticketRepositoryProvider).assignToMe(ticketId, staffId);
    // Note: The realtime stream will automatically trigger AllTicketsStream to refresh!
  }

  Future<void> markResolved(int ticketId) async {
    await ref.read(ticketRepositoryProvider).markResolved(ticketId);
  }
}

/// My tickets: derived locally from the master cache
@riverpod
class MyTickets extends _$MyTickets {
  @override
  Future<List<Ticket>> build() async {
    final allTickets = await ref.watch(allTicketsStreamProvider.future);
    final staffId = ref.read(authControllerProvider).value?.id;
    
    if (staffId == null) return [];

    // Filter in-memory where assigned_to matches current staff
    return allTickets.where((t) => t.assignedToId == staffId).toList();
  }
}

/// Completed tickets: derived locally from the master cache
@riverpod
class CompletedTickets extends _$CompletedTickets {
  @override
  Future<List<Ticket>> build() async {
    final allTickets = await ref.watch(allTicketsStreamProvider.future);

    // Filter in-memory for resolved status
    return allTickets.where((t) => t.status.name == 'resolved').toList();
  }
}

/// Internal — just a heartbeat that fires on any row change in `tickets`.
@riverpod
Stream<List<Map<String, dynamic>>> _ticketChanges(Ref ref) {
  final repo = ref.watch(ticketRepositoryProvider);
  return repo.watchTicketsRaw();
}

@riverpod
class AllTicketsStream extends _$AllTicketsStream {
  @override
  Future<List<Ticket>> build() async {
    final repo = ref.watch(ticketRepositoryProvider);

    // Re-fetch the master list whenever *anything* changes in the table
    ref.listen(_ticketChangesProvider, (_, __) {
      ref.invalidateSelf();
    });

    return repo.fetchAllTickets();
  }
}
