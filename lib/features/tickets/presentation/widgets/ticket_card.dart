import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/ticket.dart';

class TicketCard extends StatefulWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onAssignMe,
    this.onMarkResolved,
  });

  final Ticket ticket;
  final Future<void> Function()? onAssignMe;
  final Future<void> Function()? onMarkResolved;

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  bool _showOriginal = false;
  bool _isLoadingAssign = false;
  bool _isLoadingResolve = false;

  Future<void> _handleAction(
    Future<void> Function()? action, 
    bool isAssignAction,
  ) async {
    if (action == null || _isLoadingAssign || _isLoadingResolve) return;

    setState(() {
      if (isAssignAction) {
        _isLoadingAssign = true;
      } else {
        _isLoadingResolve = true;
      }
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          if (isAssignAction) {
            _isLoadingAssign = false;
          } else {
            _isLoadingResolve = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Assuming displayedDescription is calculated based on _showOriginal elsewhere in your class
    final displayedDescription = _showOriginal 
        ? (widget.ticket.translatedDescription ?? widget.ticket.description) 
        : widget.ticket.description;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${widget.ticket.id}', style: theme.textTheme.labelMedium),
                const SizedBox(width: 8),
                _StatusChip(status: widget.ticket.status),
                const Spacer(),
                Text(
                  DateFormat('d MMM, HH:mm').format(widget.ticket.createdAt.toLocal()),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(widget.ticket.categoryName ?? 'General', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    [widget.ticket.locationName, widget.ticket.roomDetail]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(' · '),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(displayedDescription, style: theme.textTheme.bodyMedium),
                ),
                if (widget.ticket.hasTranslatedDescription) ...[
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Machine-translated from the original — may not be fully accurate.',
                    child: Icon(Icons.info_outline, size: 16, color: theme.colorScheme.outline),
                  ),
                ],
              ],
            ),
            if (widget.ticket.hasTranslatedDescription)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showOriginal = !_showOriginal),
                  icon: Icon(_showOriginal ? Icons.translate : Icons.visibility_outlined, size: 16),
                  label: Text(_showOriginal ? 'Show translation' : 'Show original'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (widget.ticket.bhikkhuName != null) ...[
                  const Icon(Icons.person_outline, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.ticket.bhikkhuName!, style: theme.textTheme.bodySmall),
                ],
                const Spacer(),
                if (widget.onAssignMe != null)
                  FilledButton.tonal(
                    onPressed: (_isLoadingAssign || _isLoadingResolve)
                        ? null
                        : () => _handleAction(widget.onAssignMe, true),
                    child: _isLoadingAssign
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Assign me'),
                  ),
                if (widget.onMarkResolved != null) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (_isLoadingAssign || _isLoadingResolve)
                        ? null
                        : () => _handleAction(widget.onMarkResolved, false),
                    child: _isLoadingResolve
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Mark completed'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TicketStatus.pending => ('Pending', Colors.amber),
      TicketStatus.inProgress => ('In progress', Colors.blue),
      TicketStatus.resolved => ('Resolved', Colors.green),
      TicketStatus.closed => ('Closed', Colors.grey),
    };

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withOpacity(0.12),
      side: BorderSide(color: color.withOpacity(0.4)),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
