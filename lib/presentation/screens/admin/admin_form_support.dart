import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart'
    as gmaps_android;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart'
    as gmaps_platform;
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';

import '../../localization/app_localizations_ext.dart';
import 'admin_design.dart';

class AdminCityOption {
  final String value;
  final String label;

  const AdminCityOption({required this.value, required this.label});
}

class PickedMapLocation {
  final String label;
  final double latitude;
  final double longitude;
  final String mapsUrl;

  const PickedMapLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
  });
}

class AdminCategoryOption {
  final String value;
  final String label;

  const AdminCategoryOption({required this.value, required this.label});
}

List<AdminCityOption> adminCityOptions(BuildContext context) {
  final l10n = context.l10n;
  return <AdminCityOption>[
    AdminCityOption(value: 'Riyadh', label: l10n.cityRiyadh),
    AdminCityOption(value: 'Jeddah', label: l10n.cityJeddah),
    AdminCityOption(value: 'Mecca', label: l10n.cityMecca),
    AdminCityOption(value: 'Medina', label: l10n.cityMedina),
    AdminCityOption(value: 'Dammam', label: l10n.cityDammam),
    AdminCityOption(value: 'Khobar', label: l10n.cityKhobar),
    AdminCityOption(value: 'Abha', label: l10n.cityAbha),
    AdminCityOption(value: 'Taif', label: l10n.cityTaif),
  ];
}

List<AdminCategoryOption> adminCategoryOptions(BuildContext context) {
  final l10n = context.l10n;
  return <AdminCategoryOption>[
    AdminCategoryOption(value: 'family', label: l10n.adminCategoryFamily),
    AdminCategoryOption(value: 'cultural', label: l10n.adminCategoryCultural),
    AdminCategoryOption(value: 'adventure', label: l10n.adminCategoryAdventure),
    AdminCategoryOption(value: 'nature', label: l10n.adminCategoryNature),
    AdminCategoryOption(
      value: 'entertainment',
      label: l10n.adminCategoryEntertainment,
    ),
  ];
}

List<double> adminRatingOptions() =>
    List<double>.generate(11, (index) => index * 0.5);

String ratingLabel(double value) {
  final hasDecimal = value % 1 != 0;
  return hasDecimal ? value.toStringAsFixed(1) : value.toStringAsFixed(0);
}

String buildMapsUrl(double latitude, double longitude) {
  return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
}

Future<void> openExternalMap(String mapsUrl) async {
  final uri = Uri.tryParse(mapsUrl);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<PickedMapLocation?> showMapLocationPicker(
  BuildContext context, {
  required String title,
  required String hint,
  required String confirmLabel,
  required String selectFirstError,
  PickedMapLocation? initialLocation,
}) {
  return Navigator.of(context, rootNavigator: true).push<PickedMapLocation>(
    MaterialPageRoute<PickedMapLocation>(
      fullscreenDialog: true,
      builder: (_) => _MapLocationPickerScreen(
        title: title,
        hint: hint,
        confirmLabel: confirmLabel,
        selectFirstError: selectFirstError,
        initialLocation: initialLocation,
      ),
    ),
  );
}

String? normalizeCityValue(String? raw, List<AdminCityOption> options) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final option in options) {
    if (option.value.toLowerCase() == value.toLowerCase()) {
      return option.value;
    }
  }

  return null;
}

double? normalizeRatingValue(double? raw, List<double> options) {
  if (raw == null) {
    return null;
  }

  double nearest = options.first;
  double minDelta = (raw - nearest).abs();
  for (final value in options.skip(1)) {
    final delta = (raw - value).abs();
    if (delta < minDelta) {
      minDelta = delta;
      nearest = value;
    }
  }
  return nearest;
}

String? normalizeCategoryValue(String? raw, List<AdminCategoryOption> options) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }

  for (final option in options) {
    if (option.value.toLowerCase() == value.toLowerCase()) {
      return option.value;
    }
  }

  return null;
}

double? toDouble(dynamic raw) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw);
  }
  return null;
}

PickedMapLocation? locationFromData(Map<String, dynamic>? data) {
  if (data == null) {
    return null;
  }

  final latitude = toDouble(data['latitude']) ?? toDouble(data['lat']);
  final longitude = toDouble(data['longitude']) ?? toDouble(data['lng']);
  final locationText = (data['location'] ?? '').toString().trim();

  if (latitude == null || longitude == null) {
    return null;
  }

  final mapsUrl = (data['mapsUrl']?.toString().trim().isNotEmpty ?? false)
      ? data['mapsUrl'].toString().trim()
      : buildMapsUrl(latitude, longitude);

  final label = locationText.isNotEmpty
      ? locationText
      : '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  return PickedMapLocation(
    label: label,
    latitude: latitude,
    longitude: longitude,
    mapsUrl: mapsUrl,
  );
}

class _MapLocationPickerScreen extends StatefulWidget {
  final String title;
  final String hint;
  final String confirmLabel;
  final String selectFirstError;
  final PickedMapLocation? initialLocation;

  const _MapLocationPickerScreen({
    required this.title,
    required this.hint,
    required this.confirmLabel,
    required this.selectFirstError,
    this.initialLocation,
  });

  @override
  State<_MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<_MapLocationPickerScreen> {
  static const double _defaultLat = 23.8859;
  static const double _defaultLng = 45.0792;
  static const MethodChannel _configChannel = MethodChannel('fatripy/config');

  double? _selectedLat;
  double? _selectedLng;
  String _selectedLabel = '';
  String? _errorMessage;
  bool _isResolvingAddress = false;
  bool _isCheckingMapEngine = true;
  bool _useGoogleMap = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialLocation;
    if (initial != null) {
      _selectedLat = initial.latitude;
      _selectedLng = initial.longitude;
      _selectedLabel = initial.label;
    }
    _prepareMapEngine();
  }

  Future<void> _prepareMapEngine() async {
    final available = await _canUseGoogleMapOnThisDevice();
    if (!mounted) {
      return;
    }
    setState(() {
      _useGoogleMap = available;
      _isCheckingMapEngine = false;
    });
  }

  Future<bool> _canUseGoogleMapOnThisDevice() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    final keyConfigured = await _isMapsApiKeyConfigured();
    if (!keyConfigured) {
      return false;
    }

    try {
      final platform = gmaps_platform.GoogleMapsFlutterPlatform.instance;
      if (platform is gmaps_android.GoogleMapsFlutterAndroid) {
        await platform.initializeWithRenderer(
          gmaps_android.AndroidMapRenderer.latest,
        );
      }
      return true;
    } catch (e) {
      final message = e.toString().toLowerCase();
      if (message.contains('already initialized')) {
        return true;
      }
      return false;
    }
  }

  Future<bool> _isMapsApiKeyConfigured() async {
    try {
      final configured = await _configChannel.invokeMethod<bool>(
        'isMapsApiKeyConfigured',
      );
      return configured ?? false;
    } catch (_) {
      // If channel is unavailable, keep Google Maps path and let runtime decide.
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = _selectedLat ?? _defaultLat;
    final centerLng = _selectedLng ?? _defaultLng;

    return Scaffold(
      backgroundColor: AdminPalette.surface,
      appBar: adminAppBar(context, title: widget.title),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildMap(centerLat, centerLng),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hint,
                    style: const TextStyle(
                      color: AdminPalette.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  if (!_useGoogleMap && !_isCheckingMapEngine)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        context.l10n.adminMapFallbackNotice,
                        style: const TextStyle(
                          color: AdminPalette.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AdminPalette.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AdminPalette.blush),
                    ),
                    child: Text(
                      _isResolvingAddress
                          ? '...'
                          : (_selectedLabel.isEmpty ? '-' : _selectedLabel),
                      style: const TextStyle(color: AdminPalette.text),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.actionCancel),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: _confirmSelection,
                        icon: const Icon(Icons.check),
                        label: Text(widget.confirmLabel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(double centerLat, double centerLng) {
    if (_isCheckingMapEngine) {
      return const ColoredBox(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_useGoogleMap) {
      return gmaps.GoogleMap(
        initialCameraPosition: gmaps.CameraPosition(
          target: gmaps.LatLng(centerLat, centerLng),
          zoom: _selectedLat == null ? 5.6 : 12,
        ),
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        markers: _selectedLat == null || _selectedLng == null
            ? const <gmaps.Marker>{}
            : <gmaps.Marker>{
                gmaps.Marker(
                  markerId: const gmaps.MarkerId('picked_location'),
                  position: gmaps.LatLng(_selectedLat!, _selectedLng!),
                ),
              },
        onTap: (point) => _onTapCoordinates(point.latitude, point.longitude),
      );
    }

    return fm.FlutterMap(
      options: fm.MapOptions(
        initialCenter: latlng.LatLng(centerLat, centerLng),
        initialZoom: _selectedLat == null ? 5.6 : 12,
        onTap: (_, point) => _onTapCoordinates(point.latitude, point.longitude),
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.gradpro',
        ),
        if (_selectedLat != null && _selectedLng != null)
          fm.MarkerLayer(
            markers: [
              fm.Marker(
                point: latlng.LatLng(_selectedLat!, _selectedLng!),
                width: 42,
                height: 42,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _onTapCoordinates(double latitude, double longitude) async {
    setState(() {
      _selectedLat = latitude;
      _selectedLng = longitude;
      _selectedLabel =
          '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
      _isResolvingAddress = true;
      _errorMessage = null;
    });

    final resolved = await _reverseGeocode(latitude, longitude);
    if (!mounted) {
      return;
    }

    setState(() {
      _selectedLabel = resolved;
      _isResolvingAddress = false;
    });
  }

  Future<String> _reverseGeocode(double latitude, double longitude) async {
    try {
      final placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final mark = placemarks.first;
        final pieces = <String>[
          if ((mark.name ?? '').trim().isNotEmpty) mark.name!.trim(),
          if ((mark.locality ?? '').trim().isNotEmpty) mark.locality!.trim(),
          if ((mark.administrativeArea ?? '').trim().isNotEmpty)
            mark.administrativeArea!.trim(),
        ];
        if (pieces.isNotEmpty) {
          return pieces.join(', ');
        }
      }
    } catch (_) {
      // Fallback to coordinates when reverse geocoding is unavailable.
    }
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  void _confirmSelection() {
    final latitude = _selectedLat;
    final longitude = _selectedLng;
    if (latitude == null || longitude == null) {
      setState(() {
        _errorMessage = widget.selectFirstError;
      });
      return;
    }

    final label = _selectedLabel.trim().isEmpty
        ? '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}'
        : _selectedLabel.trim();

    Navigator.of(context).pop(
      PickedMapLocation(
        label: label,
        latitude: latitude,
        longitude: longitude,
        mapsUrl: buildMapsUrl(latitude, longitude),
      ),
    );
  }
}
