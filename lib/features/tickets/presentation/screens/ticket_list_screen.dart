import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanghacare_staff/features/tickets/data/models/ticket.dart';
import 'package:sanghacare_staff/features/tickets/presentation/providers/ticket_action_providers.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ticket_providers.dart';
import '../providers/ticket_action_providers.dart';
import '../widgets/ticket_card.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Open'),
            Tab(text: 'My Tickets'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _OpenTicketsTab(),
          _MyTicketTab(),
          _CompletedTicketsTab(),
        ],
      ),
    );
  }
}

class _OpenTicketsTab extends ConsumerWidget {
  const _OpenTicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final openTicketsAsync = ref.watch(openTicketsProvider);
    final otherStaffTicketsAsync = ref.watch(otherStaffInProgressTicketsProvider);

    // Show loading if either provider is fetching
    if (openTicketsAsync.isLoading || otherStaffTicketsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle error state if either provider throws
    if (openTicketsAsync.hasError || otherStaffTicketsAsync.hasError) {
      final error = openTicketsAsync.error ?? otherStaffTicketsAsync.error;
      return _ErrorState(
        message: error.toString(),
        onRetry: () {
          ref.invalidate(openTicketsProvider);
          ref.invalidate(otherStaffInProgressTicketsProvider);
        },
      );
    }

    final openTickets = openTicketsAsync.value ?? [];
    final otherStaffTickets = otherStaffTicketsAsync.value ?? [];

    if (openTickets.isEmpty && otherStaffTickets.isEmpty) {
      return const _EmptyState(
        icon: Icons.task_alt,
        message: 'No open or in-progress tickets right now.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          ref.refresh(openTicketsProvider.future),
          ref.refresh(otherStaffInProgressTicketsProvider.future),
        ]);
      },
      child: CustomScrollView(
        slivers: [
          // Section 1: Unassigned / Open Tickets
          if (openTickets.isNotEmpty) ...[
            const _SectionHeader(title: 'Unassigned Open Tickets'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ticket = openTickets[index];
                  return TicketCard(
                    ticket: ticket,
                    onAssignMe: () => ref
                        .read(openTicketsProvider.notifier)
                        .assignToMe(ticket.id),
                    onMarkResolved: null,
                    onTranslate: () async {
                      return await ref
                          .read(ticketActionsProvider.notifier)
                          .translateTicket(ticket.id);
                    },
                  );
                },
                childCount: openTickets.length,
              ),
            ),
          ],

          // Section 2: Other Staff In-Progress Tickets
          if (otherStaffTickets.isNotEmpty) ...[
            const _SectionHeader(title: 'In-Progress by Other Staff'),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ticket = otherStaffTickets[index];
                  return TicketCard(
                    ticket: ticket,
                    onAssignMe: null,
                    onMarkResolved: null,
                    onTranslate: () async {
                      return await ref
                          .read(ticketActionsProvider.notifier)
                          .translateTicket(ticket.id);
                    },
                  );
                },
                childCount: otherStaffTickets.length,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
    );
  }
}

class _MyTicketTab extends ConsumerWidget {
  const _MyTicketTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(myTicketsProvider),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return const _EmptyState(
            icon: Icons.inbox_outlined,
            message: 'No assigned tickets yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tickets.length,
          itemBuilder: (context, index) => TicketCard(
                ticket: tickets[index],
                onAssignMe: null,
                onMarkResolved: tickets[index].status == TicketStatus.inProgress ? () => ref.read(openTicketsProvider.notifier).markResolved(tickets[index].id) : null,
                onTranslate: () async {
                  return await ref.read(ticketActionsProvider.notifier).translateTicket(tickets[index].id);
                },
              )
        );
      },
    );
  }
}

class _CompletedTicketsTab extends ConsumerWidget {
  const _CompletedTicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(openTicketsProvider);

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(completedTicketsProvider),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return const _EmptyState(
            icon: Icons.task_alt,
            message: 'No open tickets right now.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(completedTicketsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return TicketCard(
                ticket: ticket,
                onAssignMe: null,
                onMarkResolved: null,
                onTranslate: () async {
                  return await ref.read(ticketActionsProvider.notifier).translateTicket(ticket.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
