import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/monitoring_provider.dart';

/// Live patrol tracking map widget using flutter_map
class LivePatrolMap extends ConsumerStatefulWidget {
  const LivePatrolMap({super.key});

  @override
  ConsumerState<LivePatrolMap> createState() => _LivePatrolMapState();
}

class _LivePatrolMapState extends ConsumerState<LivePatrolMap> {
  final MapController _mapController = MapController();
  
  // Default center point (can be configured based on organization's primary location)
  static const LatLng _defaultCenter = LatLng(40.7128, -74.0060); // New York
  static const double _defaultZoom = 12.0;

  @override
  void initState() {
    super.initState();
    // Fetch initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(monitoringProvider.notifier).fetchLivePatrols();
      ref.read(monitoringProvider.notifier).fetchGuardLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final livePatrols = ref.watch(livePatrolsProvider);
    final guardLocations = ref.watch(guardLocationsProvider);
    
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _defaultCenter,
            initialZoom: _defaultZoom,
            minZoom: 8.0,
            maxZoom: 18.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
          ),
          children: [
            // Base tile layer
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.patrolshield.admin',
              maxNativeZoom: 19,
              tileUpdateTransformer: _zoomFilterTransformer,
            ),
            
            // Patrol markers
            MarkerLayer(
              markers: _buildPatrolMarkers(livePatrols),
            ),
            
            // Guard location markers
            MarkerLayer(
              markers: _buildGuardMarkers(guardLocations),
            ),
            
            // Patrol routes (if available)
            PolylineLayer(
              polylines: _buildPatrolRoutes(livePatrols),
            ),
          ],
        ),
        
        // Map controls overlay
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControl(
                icon: Icons.my_location,
                tooltip: 'Center on Patrols',
                onPressed: _centerOnPatrols,
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.refresh,
                tooltip: 'Refresh Data',
                onPressed: _refreshData,
              ),
              const SizedBox(height: 8),
              _buildMapControl(
                icon: Icons.fullscreen,
                tooltip: 'Fullscreen',
                onPressed: _toggleFullscreen,
              ),
            ],
          ),
        ),
        
        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildLegend(),
        ),
      ],
    );
  }

  /// Build patrol markers on the map
  List<Marker> _buildPatrolMarkers(List<LivePatrolLocation> patrols) {
    return patrols.map((patrol) {
      Color markerColor;
      IconData markerIcon;
      
      switch (patrol.status.toLowerCase()) {
        case 'active':
        case 'in_progress':
          markerColor = Colors.green;
          markerIcon = Icons.directions_walk;
          break;
        case 'paused':
          markerColor = Colors.orange;
          markerIcon = Icons.pause;
          break;
        case 'emergency':
          markerColor = Colors.red;
          markerIcon = Icons.warning;
          break;
        case 'completed':
          markerColor = Colors.blue;
          markerIcon = Icons.check_circle;
          break;
        default:
          markerColor = Colors.grey;
          markerIcon = Icons.location_on;
      }

      return Marker(
        point: LatLng(patrol.latitude, patrol.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showPatrolDetails(patrol),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
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
            child: Icon(
              markerIcon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build guard location markers
  List<Marker> _buildGuardMarkers(List<LiveGuardLocation> guards) {
    return guards.map((guard) {
      Color markerColor;
      
      switch (guard.status.toLowerCase()) {
        case 'online':
        case 'active':
          markerColor = Colors.lightGreen;
          break;
        case 'busy':
          markerColor = Colors.yellow;
          break;
        case 'offline':
          markerColor = Colors.red;
          break;
        default:
          markerColor = Colors.grey;
      }

      return Marker(
        point: LatLng(guard.latitude, guard.longitude),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _showGuardDetails(guard),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Build patrol routes (simplified - would need route data from backend)
  List<Polyline> _buildPatrolRoutes(List<LivePatrolLocation> patrols) {
    // This is a placeholder - real implementation would require route/path data
    return [];
  }

  /// Show patrol details in a popup
  void _showPatrolDetails(LivePatrolLocation patrol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patrol.patrolName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', patrol.status.toUpperCase()),
            _detailRow('Location', '${patrol.latitude.toStringAsFixed(6)}, ${patrol.longitude.toStringAsFixed(6)}'),
            _detailRow('Last Update', _formatDateTime(patrol.lastUpdate)),
            if (patrol.assignedGuard != null)
              _detailRow('Guard', patrol.assignedGuard!.fullName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (patrol.status.toLowerCase() == 'emergency')
            ElevatedButton(
              onPressed: () {
                // Handle emergency response
                Navigator.pop(context);
                _handleEmergencyResponse(patrol);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Respond'),
            ),
        ],
      ),
    );
  }

  /// Show guard details in a popup
  void _showGuardDetails(LiveGuardLocation guard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(guard.guardName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Status', guard.status.toUpperCase()),
            _detailRow('Location', '${guard.latitude.toStringAsFixed(6)}, ${guard.longitude.toStringAsFixed(6)}'),
            _detailRow('Last Update', _formatDateTime(guard.lastUpdate)),
            if (guard.currentPatrolId != null)
              _detailRow('Current Patrol', 'Patrol #${guard.currentPatrolId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildMapControl({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legend',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _legendItem(Colors.green, 'Active Patrol'),
          _legendItem(Colors.orange, 'Paused Patrol'),
          _legendItem(Colors.red, 'Emergency'),
          _legendItem(Colors.blue, 'Completed'),
          const SizedBox(height: 4),
          _legendItem(Colors.lightGreen, 'Online Guard', isSmall: true),
          _legendItem(Colors.red, 'Offline Guard', isSmall: true),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isSmall = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 12 : 16,
            height: isSmall ? 12 : 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: isSmall ? 11 : 12),
          ),
        ],
      ),
    );
  }

  void _centerOnPatrols() {
    final patrols = ref.read(livePatrolsProvider);
    final guards = ref.read(guardLocationsProvider);
    
    final allPoints = <LatLng>[
      ...patrols.map((p) => LatLng(p.latitude, p.longitude)),
      ...guards.map((g) => LatLng(g.latitude, g.longitude)),
    ];
    
    if (allPoints.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(allPoints);
      _mapController.fitCamera(CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)));
    }
  }

  void _refreshData() {
    ref.read(monitoringProvider.notifier).fetchLivePatrols();
    ref.read(monitoringProvider.notifier).fetchGuardLocations();
  }

  void _toggleFullscreen() {
    // Placeholder for fullscreen functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fullscreen mode - Coming Soon')),
    );
  }

  void _handleEmergencyResponse(LivePatrolLocation patrol) {
    // Placeholder for emergency response functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Emergency response initiated for ${patrol.patrolName}')),
    );
  }

  /// Tile update transformer to improve performance
  TileUpdateTransformer _zoomFilterTransformer = (tileUpdate, source) {
    final shouldFilter = tileUpdate.loadingTime != null &&
        tileUpdate.loadingTime! > const Duration(milliseconds: 500);
    
    if (shouldFilter) {
      return tileUpdate.pruned(
        tileUpdate.tiles.where((tile) => 
          tile.coords.z >= 10 // Only show high-zoom tiles when slow loading
        ).toList(),
      );
    }
    
    return tileUpdate;
  };
}