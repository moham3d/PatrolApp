import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/site.dart';

/// Interactive map widget for picking location coordinates
class InteractiveMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude)? onLocationSelected;
  final double zoom;

  const InteractiveMapPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.onLocationSelected,
    this.zoom = 13.0,
  });

  @override
  State<InteractiveMapPicker> createState() => _InteractiveMapPickerState();
}

class _InteractiveMapPickerState extends State<InteractiveMapPicker> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  late LatLng _center;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // Use provided coordinates or default to a central location
    _center = LatLng(
      widget.initialLatitude ?? 40.7128, // Default to New York City
      widget.initialLongitude ?? -74.0060,
    );
    
    // If initial coordinates provided, set as selected
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = _center;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    widget.onLocationSelected?.call(location.latitude, location.longitude);
  }

  void _centerOnLocation() {
    if (_selectedLocation != null) {
      _mapController.move(_selectedLocation!, widget.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map controls
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Tap on the map to select location',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (_selectedLocation != null) ...[
                IconButton(
                  onPressed: _centerOnLocation,
                  icon: const Icon(Icons.my_location),
                  tooltip: 'Center on selected location',
                  iconSize: 20,
                ),
              ],
            ],
          ),
        ),
        
        // Map widget
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _center,
                  initialZoom: widget.zoom,
                  onTap: _onMapTap,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  // Tile layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.patrolshield.admin',
                    maxZoom: 19,
                  ),
                  
                  // Marker layer for selected location
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Coordinates display
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                    'Lng: ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}