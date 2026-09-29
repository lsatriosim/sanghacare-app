import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ticket_providers.dart';
import '../widgets/ticket_card.dart';

class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});

  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);

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
    final ticketsAsync = ref.watch(openTicketsProvider);

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(openTicketsProvider),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return const _EmptyState(
            icon: Icons.task_alt,
            message: 'No open tickets right now.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(openTicketsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final isUnassigned = ticket.assignedToId == null;

              return TicketCard(
                ticket: ticket,
                onAssignMe: isUnassigned
                    ? () => ref.read(openTicketsProvider.notifier).assignToMe(ticket.id)
                    : null,
                onMarkResolved: !isUnassigned
                    ? () => ref.read(openTicketsProvider.notifier).markResolved(ticket.id)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}

class _CompletedTicketsTab extends ConsumerWidget {
  const _CompletedTicketsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(completedTicketsProvider);

    return ticketsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(completedTicketsProvider),
      ),
      data: (tickets) {
        if (tickets.isEmpty) {
          return const _EmptyState(
            icon: Icons.inbox_outlined,
            message: 'No completed tickets yet.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: tickets.length,
          itemBuilder: (context, index) => TicketCard(ticket: tickets[index]),
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
