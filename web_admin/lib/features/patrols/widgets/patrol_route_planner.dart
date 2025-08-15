import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../shared/models/site.dart';
import '../../../shared/models/checkpoint.dart';
import '../../../features/sites/providers/sites_provider.dart';
import '../../../features/checkpoints/providers/checkpoints_provider.dart';

/// Patrol route planner with interactive maps
class PatrolRoutePlanner extends ConsumerStatefulWidget {
  const PatrolRoutePlanner({super.key});

  @override
  ConsumerState<PatrolRoutePlanner> createState() => _PatrolRoutePlannerState();
}

class _PatrolRoutePlannerState extends ConsumerState<PatrolRoutePlanner> {
  final MapController _mapController = MapController();
  Site? _selectedSite;
  List<Checkpoint> _selectedCheckpoints = [];
  List<LatLng> _routePoints = [];

  // Default map center (can be configured)
  static const LatLng _defaultCenter = LatLng(40.7128, -74.0060); // New York
  static const double _defaultZoom = 12.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sitesProvider.notifier).loadSites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sitesState = ref.watch(sitesProvider);
    final checkpointsState = ref.watch(checkpointsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left panel - Route planning controls
          SizedBox(
            width: 350,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Route Planner',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Site selection
                    _buildSiteSelector(sitesState),
                    const SizedBox(height: 16),

                    // Checkpoint selection
                    if (_selectedSite != null) ...[
                      _buildCheckpointSelector(checkpointsState),
                      const SizedBox(height: 16),
                    ],

                    // Route options
                    if (_selectedCheckpoints.isNotEmpty) ...[
                      _buildRouteOptions(),
                      const SizedBox(height: 16),

                      // Route summary
                      _buildRouteSummary(),
                      const SizedBox(height: 16),

                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Right panel - Interactive map
          Expanded(
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildInteractiveMap(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteSelector(SitesState sitesState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Site',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Site>(
          value: _selectedSite,
          decoration: const InputDecoration(
            labelText: 'Choose a site',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          items: sitesState.sites.map((site) {
            return DropdownMenuItem<Site>(
              value: site,
              child: Text(site.name),
            );
          }).toList(),
          onChanged: (site) {
            setState(() {
              _selectedSite = site;
              _selectedCheckpoints = [];
              _routePoints = [];
            });

            if (site != null) {
              _loadCheckpointsForSite(site.id);
              _centerMapOnSite(site);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCheckpointSelector(CheckpointsState checkpointsState) {
    final availableCheckpoints = checkpointsState.checkpoints
        .where((checkpoint) => checkpoint.siteId == _selectedSite!.id)
        .toList();

    if (availableCheckpoints.isEmpty) {
      return Card(
        color: Colors.orange[50],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'No checkpoints found for this site. Please add checkpoints first.'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Select Checkpoints',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCheckpoints = List.from(availableCheckpoints);
                  _generateRoute();
                });
              },
              child: const Text('Select All'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCheckpoints = [];
                  _routePoints = [];
                });
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: availableCheckpoints.length,
            itemBuilder: (context, index) {
              final checkpoint = availableCheckpoints[index];
              final isSelected = _selectedCheckpoints.contains(checkpoint);

              return CheckboxListTile(
                title: Text(checkpoint.name),
                subtitle: Text(checkpoint.description ?? 'No description'),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedCheckpoints.add(checkpoint);
                    } else {
                      _selectedCheckpoints.remove(checkpoint);
                    }
                    _generateRoute();
                  });
                },
                secondary: const Icon(Icons.location_on),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRouteOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route Options',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _optimizeRoute,
                icon: const Icon(Icons.route),
                label: const Text('Optimize Route'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reverseRoute,
                icon: const Icon(Icons.swap_vert),
                label: const Text('Reverse'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteSummary() {
    if (_selectedCheckpoints.isEmpty) return Container();

    final distance = _calculateRouteDistance();
    final estimatedTime = _calculateEstimatedTime();

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Summary',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
                Icons.flag, 'Checkpoints', '${_selectedCheckpoints.length}'),
            _buildSummaryRow(Icons.straighten, 'Distance',
                '${distance.toStringAsFixed(1)} km'),
            _buildSummaryRow(Icons.schedule, 'Est. Time',
                '${estimatedTime.toStringAsFixed(0)} min'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: _createPatrolFromRoute,
          icon: const Icon(Icons.add_task),
          label: const Text('Create Patrol'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _saveRouteTemplate,
          icon: const Icon(Icons.save),
          label: const Text('Save as Template'),
        ),
      ],
    );
  }

  Widget _buildInteractiveMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _selectedSite?.coordinates != null
            ? LatLng(_selectedSite!.latitude, _selectedSite!.longitude)
            : _defaultCenter,
        initialZoom: _selectedSite != null ? 15.0 : _defaultZoom,
        minZoom: 8.0,
        maxZoom: 18.0,
      ),
      children: [
        // Base tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.patrolshield.admin',
        ),

        // Checkpoint markers
        if (_selectedSite != null)
          MarkerLayer(
            markers: _buildCheckpointMarkers(),
          ),

        // Route polyline
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 3.0,
                color: Colors.blue,
                pattern: const StrokePattern.dotted(),
              ),
            ],
          ),
      ],
    );
  }

  List<Marker> _buildCheckpointMarkers() {
    final checkpointsState = ref.watch(checkpointsProvider);
    final siteCheckpoints = checkpointsState.checkpoints
        .where((c) => c.siteId == _selectedSite!.id)
        .toList();

    return siteCheckpoints.map((checkpoint) {
      final isSelected = _selectedCheckpoints.contains(checkpoint);
      final markerIndex = _selectedCheckpoints.indexOf(checkpoint) + 1;

      return Marker(
        point: LatLng(
          checkpoint.location.latitude,
          checkpoint.location.longitude,
        ),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _toggleCheckpointSelection(checkpoint),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isSelected
                  ? Text(
                      markerIndex.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _loadCheckpointsForSite(int siteId) {
    ref.read(checkpointsProvider.notifier).setFilters(siteId: siteId);
  }

  void _centerMapOnSite(Site site) {
    _mapController.move(
      LatLng(site.latitude, site.longitude),
      15.0,
    );
  }

  void _toggleCheckpointSelection(Checkpoint checkpoint) {
    setState(() {
      if (_selectedCheckpoints.contains(checkpoint)) {
        _selectedCheckpoints.remove(checkpoint);
      } else {
        _selectedCheckpoints.add(checkpoint);
      }
      _generateRoute();
    });
  }

  void _generateRoute() {
    if (_selectedCheckpoints.isEmpty) {
      setState(() {
        _routePoints = [];
      });
      return;
    }

    // Simple route generation - connect checkpoints in order
    final points = _selectedCheckpoints
        .map((checkpoint) =>
            LatLng(checkpoint.location.latitude, checkpoint.location.longitude))
        .toList();

    setState(() {
      _routePoints = points;
    });
  }

  void _optimizeRoute() {
    if (_selectedCheckpoints.length < 2) return;

    // Simple optimization: sort by proximity (nearest neighbor approach)
    final optimized = <Checkpoint>[];
    final remaining = List<Checkpoint>.from(_selectedCheckpoints);

    // Start with first checkpoint
    optimized.add(remaining.removeAt(0));

    while (remaining.isNotEmpty) {
      final current = optimized.last;

      // Find nearest checkpoint
      remaining.sort((a, b) {
        final distA = _calculateDistance(current.location, a.location);
        final distB = _calculateDistance(current.location, b.location);
        return distA.compareTo(distB);
      });

      optimized.add(remaining.removeAt(0));
    }

    setState(() {
      _selectedCheckpoints = optimized;
      _generateRoute();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route optimized for shortest distance')),
    );
  }

  void _reverseRoute() {
    setState(() {
      _selectedCheckpoints = _selectedCheckpoints.reversed.toList();
      _generateRoute();
    });
  }

  double _calculateRouteDistance() {
    if (_routePoints.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < _routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        Location(
          latitude: _routePoints[i].latitude,
          longitude: _routePoints[i].longitude,
        ),
        Location(
          latitude: _routePoints[i + 1].latitude,
          longitude: _routePoints[i + 1].longitude,
        ),
      );
    }
    return totalDistance;
  }

  double _calculateEstimatedTime() {
    // Estimate 3 km/h walking speed + 2 minutes per checkpoint
    final distance = _calculateRouteDistance();
    final walkingTime = (distance / 3.0) * 60; // minutes
    final checkpointTime =
        _selectedCheckpoints.length * 2.0; // 2 minutes per checkpoint
    return walkingTime + checkpointTime;
  }

  double _calculateDistance(Location point1, Location point2) {
    const Distance distance = Distance();
    return distance.as(
        LengthUnit.Kilometer,
        LatLng(point1.latitude, point1.longitude),
        LatLng(point2.latitude, point2.longitude));
  }

  void _createPatrolFromRoute() {
    if (_selectedSite == null || _selectedCheckpoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a site and checkpoints first')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Patrol'),
        content: const Text(
            'This will create a new patrol with the selected route. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCreatePatrolDialog();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showCreatePatrolDialog() {
    // TODO: Show create patrol dialog with pre-filled route information
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Create patrol dialog functionality coming soon')),
    );
  }

  void _saveRouteTemplate() {
    if (_selectedCheckpoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select checkpoints first')),
      );
      return;
    }

    // TODO: Implement route template saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route template functionality coming soon')),
    );
  }
}
