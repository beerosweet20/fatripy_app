import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class PlanGenerationResult {
  final List<Map<String, dynamic>> generatedPlans;
  final double? aiElapsedMs;

  const PlanGenerationResult({
    required this.generatedPlans,
    required this.aiElapsedMs,
  });

  factory PlanGenerationResult.fromMap(Map<String, dynamic> data) {
    final generatedRaw = data['generatedPlans'];
    final generatedPlans = generatedRaw is List
        ? generatedRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
        : const <Map<String, dynamic>>[];
    final aiElapsedMs = data['aiElapsedMs'] is num
        ? (data['aiElapsedMs'] as num).toDouble()
        : double.tryParse('${data['aiElapsedMs']}');

    return PlanGenerationResult(
      generatedPlans: generatedPlans,
      aiElapsedMs: aiElapsedMs,
    );
  }
}

class PlanApiClient {
  static const String _defaultApiBaseUrl = 'http://10.0.2.2:8000';
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultApiBaseUrl,
  );

  /// Pass `--dart-define=API_BASE_URL=https://your-host` to override.
  final String baseUrl;

  PlanApiClient({String? baseUrl})
    : baseUrl = (baseUrl ?? _apiBaseUrlFromEnv).trim().isEmpty
          ? _defaultApiBaseUrl
          : (baseUrl ?? _apiBaseUrlFromEnv).trim();

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      final lower = trimmed.toLowerCase();
      if (lower.contains('free')) return 0.0;
      final normalized = lower
          .replaceAll(',', ' ')
          .replaceAll(RegExp(r'[^\d\.\-\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      if (normalized.isEmpty) return null;
      final matches = RegExp(r'-?\d+(?:\.\d+)?')
          .allMatches(normalized)
          .map((m) => double.tryParse(m.group(0)!))
          .whereType<double>()
          .toList();
      if (matches.isEmpty) return null;
      if (matches.length == 1) return matches.first;
      return (matches[0] + matches[1]) / 2.0;
    }
    return null;
  }

  List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  Map<String, dynamic> _normalizeAccommodation(Map<String, dynamic> raw) {
    final name =
        (raw['name'] ??
                raw['title'] ??
                raw['hotelName'] ??
                raw['accommodationName'])
            ?.toString()
            .trim();
    final resolvedId = raw['accommodationId'] ?? raw['hotelId'] ?? raw['id'];
    return {
      'accommodationId': resolvedId?.toString(),
      'id': (raw['id'] ?? resolvedId)?.toString(),
      'hotelId': raw['hotelId']?.toString(),
      'name': (name == null || name.isEmpty) ? 'Unknown Hotel' : name,
      'pricePerNight': _toDouble(raw['pricePerNight']),
      'priceMin': _toDouble(raw['priceMin']),
      'priceMax': _toDouble(raw['priceMax']),
      'lat': _toDouble(raw['lat'] ?? raw['latitude']),
      'lng': _toDouble(raw['lng'] ?? raw['longitude']),
      'rating': _toDouble(raw['rating']),
      'location': (raw['location'] ?? raw['address'])?.toString(),
      'amenities': raw['amenities'],
      'facilities': _toStringList(raw['facilities']),
      'planType': raw['planType']?.toString(),
      'googleMaps': (raw['googleMaps'] ?? raw['mapsUrl'])?.toString(),
      'bookingUrl': raw['bookingUrl']?.toString(),
      'mapsUrl': (raw['mapsUrl'] ?? raw['googleMaps'])?.toString(),
    };
  }

  Map<String, dynamic> _normalizeActivity(Map<String, dynamic> raw) {
    final name = (raw['name'] ?? raw['title'] ?? raw['activityName'])
        ?.toString()
        .trim();
    return {
      'activityId': (raw['activityId'] ?? raw['id'])?.toString(),
      'id': (raw['id'] ?? raw['activityId'])?.toString(),
      'name': (name == null || name.isEmpty) ? 'Unknown Activity' : name,
      'price': raw['price'],
      'lat': _toDouble(raw['lat'] ?? raw['latitude']),
      'lng': _toDouble(raw['lng'] ?? raw['longitude']),
      'rating': _toDouble(raw['rating']),
      'location': (raw['location'] ?? raw['address'])?.toString(),
      'open': raw['open']?.toString(),
      'close': raw['close']?.toString(),
      'time': raw['time']?.toString(),
      'openHours': raw['openHours']?.toString(),
      'closeHours': raw['closeHours']?.toString(),
      'googleMaps': raw['googleMaps']?.toString(),
      'bookingUrl': raw['bookingUrl']?.toString(),
      'mapsUrl': raw['mapsUrl']?.toString(),
      'distanceType': raw['distanceType']?.toString(),
    };
  }

  Map<String, dynamic> _normalizeEvent(Map<String, dynamic> raw) {
    final title = (raw['title'] ?? raw['name'] ?? raw['eventName'])
        ?.toString()
        .trim();
    return {
      'title': (title == null || title.isEmpty) ? 'Event' : title,
      'date': raw['date']?.toString(),
      'time': raw['time']?.toString(),
      'location': raw['location']?.toString(),
      'description': raw['description']?.toString(),
      'city': raw['city']?.toString(),
      'mapsUrl': raw['mapsUrl']?.toString(),
    };
  }

  Future<PlanGenerationResult> generatePlans({
    required String city,
    required double budget,
    required int days,
    required List<String> familyAges,
    required List<Map<String, dynamic>> accommodations,
    required List<Map<String, dynamic>> activities,
    required List<Map<String, dynamic>> events,
    String? startDate,
    String? endDate,
  }) async {
    final url = Uri.parse('$baseUrl/generate-plans');
    final normalizedAccommodations = accommodations
        .map(_normalizeAccommodation)
        .toList();
    final normalizedActivities = activities.map(_normalizeActivity).toList();
    final normalizedEvents = events.map(_normalizeEvent).toList();

    final payload = {
      'city': city,
      'budget': budget,
      'days': days,
      'familyAges': familyAges,
      'accommodations': normalizedAccommodations,
      'activities': normalizedActivities,
      'events': normalizedEvents,
      if (startDate?.trim().isNotEmpty ?? false) 'start_date': startDate!.trim(),
      if (endDate?.trim().isNotEmpty ?? false) 'end_date': endDate!.trim(),
    };

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 25));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('Unexpected API response format.');
      }
      return PlanGenerationResult.fromMap(decoded);
    } else {
      final responseText = response.body.length > 600
          ? '${response.body.substring(0, 600)}...'
          : response.body;
      throw Exception(
        'Failed to generate plans from API: ${response.statusCode} | $responseText',
      );
    }
  }
}
