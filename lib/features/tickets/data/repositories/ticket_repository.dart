import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ticket.dart';

/// All ticket-related Supabase calls live here. Nothing above this layer
/// (providers, widgets) should import `supabase_flutter` directly — that
/// keeps the backend swappable and the UI trivially testable with a fake
/// repository.
class TicketRepository {
  TicketRepository(this._client);

  final SupabaseClient _client;
  final String baseUrl = "https://sanghacare.vercel.app";

  static const _selectWithJoins = '''
    *,
    bhikkhu:bhikkhu_id (full_name),
    location:location_id (name),
    category:category_id (name),
    assignee:assigned_to (full_name)
  ''';

  /// Staff view: unassigned + tickets assigned to nobody yet, and anything
  /// not yet resolved/closed. Adjust the filter here if staff should also
  /// see tickets assigned to *other* staff.
  Future<List<Ticket>> fetchOpenTickets() async {
    final rows = await _client
        .from('tickets')
        .select(_selectWithJoins)
        .inFilter('status', ['pending', 'in_progress'])
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Ticket.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ticket>> fetchMyTickets(String staffId) async {
    final rows = await _client
        .from('tickets')
        .select(_selectWithJoins)
        .eq('assigned_to', staffId)
        .order('created_at', ascending: false);

    return (rows as List)
        .map((row) => Ticket.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  Future<List<Ticket>> fetchCompletedTickets() async {
    final rows = await _client
        .from('tickets')
        .select(_selectWithJoins)
        .eq('status', 'resolved')
        .order('updated_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((row) => Ticket.fromMap(row as Map<String, dynamic>))
        .toList();
  }

  /// "Assign me" — the staff member currently signed in takes the ticket.
  Future<void> assignToMe(int ticketId, String staffId) async {
    await _client.from('tickets').update({
      'assigned_to': staffId,
      'status': 'in_progress',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', ticketId);
  }

  Future<void> markResolved(int ticketId) async {
    await _client.from('tickets').update({
      'status': 'resolved',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', ticketId);
  }

  /// Fetches all relevant tickets in a single network call.
  Future<List<Ticket>> fetchAllTickets() async {
  final rows = await _client
      .from('tickets')
      .select(_selectWithJoins)
      .order('created_at', ascending: false)
      .limit(200); // Set a reasonable safety limit if your table grows large

  return (rows as List)
      .map((row) => Ticket.fromMap(row as Map<String, dynamic>))
      .toList();
  }

  Future<Map<String, dynamic>> translateTicket(int ticketId) async {
  // 1. Get the current user session token from Supabase
  final session = Supabase.instance.client.auth.currentSession;
  final accessToken = session?.accessToken;

  final response = await http.post(
    Uri.parse('$baseUrl/api/translate-ticket'),
    headers: {
      'Content-Type': 'application/json',
      // 2. Attach the token so Next.js recognizes the authenticated user
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'ticketId': ticketId}),
  );

  final result = jsonDecode(response.body);

  if (response.statusCode != 200) {
    throw Exception(result['error'] ?? 'Failed to translate ticket');
  }

  return result['translations'] as Map<String, dynamic>;
}

  /// Realtime stream of ticket changes, so the list updates live when
  /// another staff member assigns/resolves a ticket. Riverpod's
  /// `StreamNotifier` (see ticket_providers.dart) consumes this directly.
  Stream<List<Map<String, dynamic>>> watchTicketsRaw() {
    return _client
        .from('tickets')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }
}
