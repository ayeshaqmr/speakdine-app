import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:speak_dine/utils/toast_helper.dart';

/// Default center: Lahore, Pakistan
const _defaultLat = 31.5204;
const _defaultLng = 74.3587;

/// A reusable widget for picking a location on an OpenStreetMap map.
/// Works inside a dialog or full page.
class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationSelected,
  });

  final double? initialLat;
  final double? initialLng;
  final void Function(double lat, double lng, String address) onLocationSelected;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late MapController _mapController;
  late LatLng _selectedPoint;
  String _address = '';
  bool _loadingAddress = false;
  bool _loadingMyLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPoint = LatLng(
      widget.initialLat ?? _defaultLat,
      widget.initialLng ?? _defaultLng,
    );
    _reverseGeocode(_selectedPoint);
  }

  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _loadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted) return;
      final address = placemarks.isNotEmpty
          ? _formatPlacemark(placemarks.first)
          : '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
      setState(() {
        _address = address;
        _loadingAddress = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _address =
            '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
        _loadingAddress = false;
      });
    }
  }

  String _formatPlacemark(Placemark p) {
    final parts = <String>[];
    if (p.street?.isNotEmpty ?? false) parts.add(p.street!);
    if (p.subLocality?.isNotEmpty ?? false) parts.add(p.subLocality!);
    if (p.locality?.isNotEmpty ?? false) parts.add(p.locality!);
    if (p.administrativeArea?.isNotEmpty ?? false) parts.add(p.administrativeArea!);
    if (p.country?.isNotEmpty ?? false) parts.add(p.country!);
    return parts.join(', ');
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedPoint = point);
    _mapController.move(point, _mapController.camera.zoom);
    _reverseGeocode(point);
  }

  Future<void> _useMyLocation() async {
    setState(() => _loadingMyLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        showAppToast(context, 'Location services are disabled. Please enable them.');
        setState(() => _loadingMyLocation = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showAppToast(
          context,
          'Location permission permanently denied. Please enable in settings.',
        );
        setState(() => _loadingMyLocation = false);
        return;
      }
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        showAppToast(context, 'Location permission denied.');
        setState(() => _loadingMyLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedPoint = point;
        _loadingMyLocation = false;
      });
      _mapController.move(point, 16.0);
      _reverseGeocode(point);
    } catch (e) {
      if (!mounted) return;
      showAppToast(
        context,
        'Could not get your location. Please check permissions and try again.',
      );
      setState(() => _loadingMyLocation = false);
    }
  }

  void _confirmLocation() {
    widget.onLocationSelected(
      _selectedPoint.latitude,
      _selectedPoint.longitude,
      _address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPoint,
                initialZoom: 14,
                onTap: _onMapTap,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.speakdine.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPoint,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: Icon(
                        RadixIcons.crosshair1,
                        size: 48,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingAddress)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Getting address...', style: TextStyle(color: primary)),
              ],
            ),
          )
        else if (_address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              _address,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).muted().small(),
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlineButton(
                onPressed: _loadingMyLocation ? null : _useMyLocation,
                child: _loadingMyLocation
                    ? Center(
                        child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primary,
                          ),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(RadixIcons.crosshair1, size: 16, color: primary),
                            const SizedBox(width: 8),
                            const Text('Use My Location'),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                onPressed: _confirmLocation,
                child: const Text('Confirm Location'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
