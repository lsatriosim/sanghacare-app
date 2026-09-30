import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sanghacare_staff/features/auth/presentation/providers/auth_provider.dart';
import 'package:sanghacare_staff/features/tickets/presentation/providers/ticket_providers.dart';

part 'ticket_action_providers.g.dart';

@riverpod
class TicketActions extends _$TicketActions {
  @override
  void build() {}

  Future<void> assignToMe(int ticketId) async {
    final staffId = ref.read(authControllerProvider).value?.id;
    if (staffId == null) return;
    
    await ref.read(ticketRepositoryProvider).assignToMe(ticketId, staffId);
  }

  Future<void> markResolved(int ticketId) async {
    await ref.read(ticketRepositoryProvider).markResolved(ticketId);
  }

  Future<Map<String, dynamic>?> translateTicket(int ticketId) async {
    try {
      final repo = ref.read(ticketRepositoryProvider);
      return await repo.translateTicket(ticketId);
    } catch (e) {
      // Handle error or bubble up to UI state
      debugPrint('Translation error: $e');
      rethrow;
    }
  }
}