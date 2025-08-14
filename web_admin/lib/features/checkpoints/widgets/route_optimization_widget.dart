import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

import '../../../shared/models/checkpoint.dart';
import '../../../shared/models/site.dart';
import '../../../features/sites/providers/sites_provider.dart';
import '../providers/checkpoints_provider.dart';

/// Widget for visualizing and optimizing checkpoint routes
class RouteOptimizationWidget extends ConsumerStatefulWidget {
  const RouteOptimizationWidget({super.key});

  @override
  ConsumerState<RouteOptimizationWidget> createState() => _RouteOptimizationWidgetState();
}

class _RouteOptimizationWidgetState extends ConsumerState<RouteOptimizationWidget> {
  final MapController _mapController = MapController();
  Site? _selectedSite;
  List<Checkpoint> _selectedCheckpoints = [];
  List<RouteSegment> _optimizedRoute = [];
  RouteAnalysis? _routeAnalysis;
  String _optimizationMethod = 'nearest_neighbor';
  bool _isOptimizing = false;
  
  // Default map center
  static const LatLng _defaultCenter = LatLng(40.7128, -74.0060);

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

    return Dialog(
      child: Container(
        width: 1000,
        height: 700,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Route Optimization',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: Row(
                children: [
                  // Left panel - Controls
                  SizedBox(
                    width: 350,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Site selection
                            _buildSiteSelector(sitesState),
                            const SizedBox(height: 16),
                            
                            // Checkpoint selection
                            if (_selectedSite != null) ...[
                              _buildCheckpointSelector(checkpointsState),
                              const SizedBox(height: 16),
                            ],
                            
                            // Optimization controls
                            if (_selectedCheckpoints.length >= 2) ...[
                              _buildOptimizationControls(),
                              const SizedBox(height: 16),
                            ],
                            
                            // Route analysis
                            if (_routeAnalysis != null) ...[
                              _buildRouteAnalysis(),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Right panel - Map
                  Expanded(
                    child: _buildMap(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              _optimizedRoute = [];
              _routeAnalysis = null;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Checkpoints',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCheckpoints = List.from(availableCheckpoints);
                });
              },
              child: const Text('All'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCheckpoints = [];
                  _optimizedRoute = [];
                  _routeAnalysis = null;
                });
              },
              child: const Text('Clear'),
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
          child: availableCheckpoints.isEmpty
              ? const Center(
                  child: Text('No checkpoints available for this site'),
                )
              : ListView.builder(
                  itemCount: availableCheckpoints.length,
                  itemBuilder: (context, index) {
                    final checkpoint = availableCheckpoints[index];
                    final isSelected = _selectedCheckpoints.contains(checkpoint);
                    
                    return CheckboxListTile(
                      dense: true,
                      title: Text(checkpoint.name),
                      subtitle: Text(
                        checkpoint.description ?? 'No description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: isSelected,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedCheckpoints.add(checkpoint);
                          } else {
                            _selectedCheckpoints.remove(checkpoint);
                          }
                          _optimizedRoute = [];
                          _routeAnalysis = null;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildOptimizationControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Optimization',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        // Optimization method
        DropdownButtonFormField<String>(
          value: _optimizationMethod,
          decoration: const InputDecoration(
            labelText: 'Method',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'nearest_neighbor',
              child: Text('Nearest Neighbor'),
            ),
            DropdownMenuItem(
              value: 'genetic_algorithm',
              child: Text('Genetic Algorithm'),
            ),
            DropdownMenuItem(
              value: 'simulated_annealing',
              child: Text('Simulated Annealing'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _optimizationMethod = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        
        // Optimize button
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isOptimizing ? null : _optimizeRoute,
            icon: _isOptimizing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high),
            label: Text(_isOptimizing ? 'Optimizing...' : 'Optimize Route'),
          ),
        ),
        
        if (_optimizedRoute.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveOptimizedRoute,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exportRoute,
                  icon: const Icon(Icons.download),
                  label: const Text('Export'),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRouteAnalysis() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Route Analysis',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 12),
            
            _buildAnalysisRow('Total Distance', '${_routeAnalysis!.totalDistance.toStringAsFixed(2)} km'),
            _buildAnalysisRow('Estimated Time', '${_routeAnalysis!.estimatedTime.toStringAsFixed(0)} min'),
            _buildAnalysisRow('Efficiency Score', '${(_routeAnalysis!.efficiencyScore * 100).toStringAsFixed(1)}%'),
            _buildAnalysisRow('Checkpoints', '${_routeAnalysis!.checkpointCount}'),
            
            if (_routeAnalysis!.improvementPercentage > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_routeAnalysis!.improvementPercentage.toStringAsFixed(1)}% improvement',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _selectedSite?.coordinates != null 
            ? LatLng(_selectedSite!.coordinates!.latitude, _selectedSite!.coordinates!.longitude)
            : _defaultCenter,
        initialZoom: _selectedSite != null ? 16.0 : 12.0,
        minZoom: 8.0,
        maxZoom: 18.0,
      ),
      children: [
        // Base tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.patrolshield.admin',
        ),
        
        // Route lines
        if (_optimizedRoute.isNotEmpty)
          PolylineLayer(
            polylines: _optimizedRoute.map((segment) => Polyline(
              points: [segment.from, segment.to],
              strokeWidth: 3.0,
              color: _getSegmentColor(segment),
            )).toList(),
          ),
        
        // Checkpoint markers
        if (_selectedSite != null)
          MarkerLayer(
            markers: _buildCheckpointMarkers(),
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
      final routeIndex = _getCheckpointRouteIndex(checkpoint);
      
      return Marker(
        point: LatLng(
          checkpoint.location.latitude,
          checkpoint.location.longitude,
        ),
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: routeIndex >= 0
                ? Text(
                    (routeIndex + 1).toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  )
                : Icon(
                    isSelected ? Icons.location_on : Icons.location_off,
                    color: Colors.white,
                    size: 24,
                  ),
          ),
        ),
      );
    }).toList();
  }

  Color _getSegmentColor(RouteSegment segment) {
    // Color based on efficiency
    if (segment.efficiency > 0.8) return Colors.green;
    if (segment.efficiency > 0.6) return Colors.orange;
    return Colors.red;
  }

  int _getCheckpointRouteIndex(Checkpoint checkpoint) {
    for (int i = 0; i < _optimizedRoute.length; i++) {
      final segment = _optimizedRoute[i];
      if ((segment.from.latitude == checkpoint.location.latitude &&
           segment.from.longitude == checkpoint.location.longitude) ||
          (segment.to.latitude == checkpoint.location.latitude &&
           segment.to.longitude == checkpoint.location.longitude)) {
        return i;
      }
    }
    return -1;
  }

  void _loadCheckpointsForSite(int siteId) {
    ref.read(checkpointsProvider.notifier).setFilters(siteId: siteId);
  }

  void _centerMapOnSite(Site site) {
    if (site.coordinates != null) {
      _mapController.move(
        LatLng(site.coordinates!.latitude, site.coordinates!.longitude),
        16.0,
      );
    }
  }

  Future<void> _optimizeRoute() async {
    if (_selectedCheckpoints.length < 2) return;

    setState(() {
      _isOptimizing = true;
    });

    try {
      // Simulate optimization process
      await Future.delayed(const Duration(seconds: 2));
      
      final optimizedRoute = _performRouteOptimization();
      final analysis = _analyzeRoute(optimizedRoute);
      
      setState(() {
        _optimizedRoute = optimizedRoute;
        _routeAnalysis = analysis;
        _isOptimizing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Route optimization completed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isOptimizing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Optimization failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<RouteSegment> _performRouteOptimization() {
    switch (_optimizationMethod) {
      case 'nearest_neighbor':
        return _nearestNeighborOptimization();
      case 'genetic_algorithm':
        return _geneticAlgorithmOptimization();
      case 'simulated_annealing':
        return _simulatedAnnealingOptimization();
      default:
        return _nearestNeighborOptimization();
    }
  }

  List<RouteSegment> _nearestNeighborOptimization() {
    if (_selectedCheckpoints.isEmpty) return [];
    
    final route = <RouteSegment>[];
    final remaining = List<Checkpoint>.from(_selectedCheckpoints);
    Checkpoint current = remaining.removeAt(0);
    
    while (remaining.isNotEmpty) {
      // Find nearest checkpoint
      remaining.sort((a, b) {
        final distA = _calculateDistance(current.location, a.location);
        final distB = _calculateDistance(current.location, b.location);
        return distA.compareTo(distB);
      });
      
      final next = remaining.removeAt(0);
      final distance = _calculateDistance(current.location, next.location);
      
      route.add(RouteSegment(
        from: LatLng(current.location.latitude, current.location.longitude),
        to: LatLng(next.location.latitude, next.location.longitude),
        distance: distance,
        efficiency: 1.0 - (distance / 1000), // Simple efficiency calculation
        fromCheckpoint: current,
        toCheckpoint: next,
      ));
      
      current = next;
    }
    
    return route;
  }

  List<RouteSegment> _geneticAlgorithmOptimization() {
    // Simplified genetic algorithm simulation
    return _nearestNeighborOptimization();
  }

  List<RouteSegment> _simulatedAnnealingOptimization() {
    // Simplified simulated annealing simulation
    return _nearestNeighborOptimization();
  }

  RouteAnalysis _analyzeRoute(List<RouteSegment> route) {
    if (route.isEmpty) {
      return RouteAnalysis(
        totalDistance: 0,
        estimatedTime: 0,
        efficiencyScore: 0,
        checkpointCount: _selectedCheckpoints.length,
        improvementPercentage: 0,
      );
    }
    
    final totalDistance = route.fold<double>(0, (sum, segment) => sum + segment.distance);
    final estimatedTime = (totalDistance / 3.0) * 60 + (_selectedCheckpoints.length * 3); // 3 km/h + 3 min per checkpoint
    final efficiencyScore = route.fold<double>(0, (sum, segment) => sum + segment.efficiency) / route.length;
    
    // Calculate improvement (simplified)
    final originalDistance = _calculateOriginalRouteDistance();
    final improvementPercentage = originalDistance > 0 
        ? ((originalDistance - totalDistance) / originalDistance) * 100
        : 0;
    
    return RouteAnalysis(
      totalDistance: totalDistance,
      estimatedTime: estimatedTime,
      efficiencyScore: efficiencyScore,
      checkpointCount: _selectedCheckpoints.length,
      improvementPercentage: math.max(0, improvementPercentage),
    );
  }

  double _calculateOriginalRouteDistance() {
    if (_selectedCheckpoints.length < 2) return 0;
    
    double total = 0;
    for (int i = 0; i < _selectedCheckpoints.length - 1; i++) {
      total += _calculateDistance(
        _selectedCheckpoints[i].location,
        _selectedCheckpoints[i + 1].location,
      );
    }
    return total;
  }

  double _calculateDistance(Location point1, Location point2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, 
        LatLng(point1.latitude, point1.longitude), 
        LatLng(point2.latitude, point2.longitude));
  }

  void _saveOptimizedRoute() {
    // TODO: Implement route saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route saving functionality coming soon')),
    );
  }

  void _exportRoute() {
    // TODO: Implement route export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Route export functionality coming soon')),
    );
  }
}

/// Model for route segments
class RouteSegment {
  final LatLng from;
  final LatLng to;
  final double distance;
  final double efficiency;
  final Checkpoint fromCheckpoint;
  final Checkpoint toCheckpoint;

  const RouteSegment({
    required this.from,
    required this.to,
    required this.distance,
    required this.efficiency,
    required this.fromCheckpoint,
    required this.toCheckpoint,
  });
}

/// Model for route analysis
class RouteAnalysis {
  final double totalDistance;
  final double estimatedTime;
  final double efficiencyScore;
  final int checkpointCount;
  final double improvementPercentage;

  const RouteAnalysis({
    required this.totalDistance,
    required this.estimatedTime,
    required this.efficiencyScore,
    required this.checkpointCount,
    required this.improvementPercentage,
  });
}

/// Location class helper
class Location {
  final double latitude;
  final double longitude;

  const Location(this.latitude, this.longitude);
}