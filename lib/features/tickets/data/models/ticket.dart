/// Mirrors the `ticket_status` Postgres enum.
enum TicketStatus {
  pending,
  inProgress,
  resolved,
  closed;

  static TicketStatus fromDb(String? value) {
    switch (value) {
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'pending':
      default:
        return TicketStatus.pending;
    }
  }

  String toDb() {
    switch (this) {
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
      case TicketStatus.pending:
        return 'pending';
    }
  }
}

/// A single ticket, as the staff app needs it.
///
/// Immutable by convention (all fields `final`), with a `copyWith` for
/// the few places we need to produce an updated copy (optimistic UI
/// updates after assign/resolve).
class Ticket {
  final int id;
  final String? bhikkhuName;
  final String? locationName;
  final String? roomDetail;
  final String? categoryName;
  final String description;
  final TicketStatus status;
  final String? assignedToId;
  final String? assignedToName;
  final DateTime createdAt;

  // Translation payload, as written by the web app's translate-ticket route.
  final String? translatedDescription;
  final String? translatedRoomDetail;

  const Ticket({
    required this.id,
    required this.bhikkhuName,
    required this.locationName,
    required this.roomDetail,
    required this.categoryName,
    required this.description,
    required this.status,
    required this.assignedToId,
    required this.assignedToName,
    required this.createdAt,
    required this.translatedDescription,
    required this.translatedRoomDetail,
  });

  /// Built from the same joined shape the web app already selects:
  /// tickets.*, bhikkhu:bhikkhu_id(full_name), location:location_id(name),
  /// category:category_id(name), assignee:assigned_to(full_name)
  factory Ticket.fromMap(Map<String, dynamic> map) {
    final translations = map['translations'] as Map<String, dynamic>?;
    final idTranslation = translations?['id'] as Map<String, dynamic>?;

    return Ticket(
      id: map['id'] as int,
      bhikkhuName: (map['bhikkhu'] as Map<String, dynamic>?)?['full_name'] as String?,
      locationName: (map['location'] as Map<String, dynamic>?)?['name'] as String?,
      roomDetail: map['room_detail'] as String?,
      categoryName: (map['category'] as Map<String, dynamic>?)?['name'] as String?,
      description: (map['description'] as String?) ?? '',
      status: TicketStatus.fromDb(map['status'] as String?),
      assignedToId: map['assigned_to'] as String?,
      assignedToName: (map['assignee'] as Map<String, dynamic>?)?['full_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      translatedDescription: idTranslation?['description'] as String?,
      translatedRoomDetail: idTranslation?['room_detail'] as String?,
    );
  }

  /// True Indonesian text differs from the raw text and actually exists.
  bool get hasTranslatedDescription =>
      translatedDescription != null && translatedDescription != description;

  Ticket copyWith({
    TicketStatus? status,
    String? assignedToId,
    String? assignedToName,
  }) {
    return Ticket(
      id: id,
      bhikkhuName: bhikkhuName,
      locationName: locationName,
      roomDetail: roomDetail,
      categoryName: categoryName,
      description: description,
      status: status ?? this.status,
      assignedToId: assignedToId ?? this.assignedToId,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt,
      translatedDescription: translatedDescription,
      translatedRoomDetail: translatedRoomDetail,
    );
  }
}
