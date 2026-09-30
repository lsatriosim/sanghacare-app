import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/ticket.dart';

class TicketCard extends StatefulWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onAssignMe,
    this.onMarkResolved,
    this.onTranslate,
  });

  final Ticket ticket;
  final Future<void> Function()? onAssignMe;
  final Future<void> Function()? onMarkResolved;
  final Future<Map<String, dynamic>?> Function()? onTranslate;

  @override
  State<TicketCard> createState() => _TicketCardState();
}

class _TicketCardState extends State<TicketCard> {
  bool _showOriginal = false;
  bool _isLoadingAssign = false;
  bool _isLoadingResolve = false;
  bool _isTranslating = false;

  String? _translatedDescription;
  String? _translatedRoomDetail;

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

  Future<void> _handleTranslation() async {
    if (widget.onTranslate == null || _isTranslating) return;

    setState(() => _isTranslating = true);

    try {
      final result = await widget.onTranslate!();
      if (result != null) {
        setState(() {
          _translatedDescription = result['description'];
          _translatedRoomDetail = result['room_detail'];
          _showOriginal = false; // Automatically show the translation
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isTranslating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final activeDescription = _showOriginal 
        ? widget.ticket.description 
        : (_translatedDescription ?? widget.ticket.translatedDescription ?? widget.ticket.description);

    final activeRoomDetail = _showOriginal 
        ? widget.ticket.roomDetail 
        : (_translatedRoomDetail ?? widget.ticket.roomDetail);

    final locationString = [widget.ticket.locationName, activeRoomDetail]
        .where((s) => s != null && s.isNotEmpty)
        .join(' · ');

    final hasActiveTranslation = _translatedDescription != null || widget.ticket.hasTranslatedDescription;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: ID, Status, Date
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
            // Category Row
            Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(widget.ticket.categoryName ?? 'General', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 4),
            // Location & Room Detail Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(locationString, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Description Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(activeDescription, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Translation Button Row
            Row(
              children: [
                if (hasActiveTranslation)
                  TextButton.icon(
                    onPressed: () => setState(() => _showOriginal = !_showOriginal),
                    icon: Icon(_showOriginal ? Icons.translate : Icons.visibility_outlined, size: 16),
                    label: Text(_showOriginal ? 'Terjemahkan ke Indonesia' : 'Tampilkan Asli'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                  )
                else
                  TextButton.icon(
                    onPressed: _isTranslating ? null : _handleTranslation,
                    icon: _isTranslating 
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.translate, size: 16),
                    label: Text(_isTranslating ? 'Menerjemahkan...' : 'Terjemahkan ke Indonesia'),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                  ),
              ],
            ),
            // Footer Row: Assignee Info & Action Buttons
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