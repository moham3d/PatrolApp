import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/monitoring_provider.dart';

/// Guard locations panel widget with real-time status monitoring
class GuardLocationsPanel extends ConsumerStatefulWidget {
  const GuardLocationsPanel({super.key});

  @override
  ConsumerState<GuardLocationsPanel> createState() => _GuardLocationsPanelState();
}

class _GuardLocationsPanelState extends ConsumerState<GuardLocationsPanel> {
  String _selectedFilter = 'all';
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final guardLocations = ref.watch(guardLocationsProvider);
    final filteredGuards = _filterGuards(guardLocations);
    
    return Column(
      children: [
        // Header with search and filter
        _buildHeader(),
        const SizedBox(height: 16),
        
        // Summary stats
        _buildSummaryStats(guardLocations),
        const SizedBox(height: 16),
        
        // Guards list
        Expanded(
          child: filteredGuards.isEmpty 
              ? _buildEmptyState()
              : _buildGuardsList(filteredGuards),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search guards...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Guards',
              onSelected: (value) {
                setState(() {
                  _selectedFilter = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'all',
                  child: Text('All Guards'),
                ),
                const PopupMenuItem(
                  value: 'online',
                  child: Text('Online Only'),
                ),
                const PopupMenuItem(
                  value: 'offline',
                  child: Text('Offline Only'),
                ),
                const PopupMenuItem(
                  value: 'on_patrol',
                  child: Text('On Patrol'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryStats(List<LiveGuardLocation> guards) {
    final onlineCount = guards.where((g) => g.status.toLowerCase() == 'online').length;
    final offlineCount = guards.where((g) => g.status.toLowerCase() == 'offline').length;
    final onPatrolCount = guards.where((g) => g.currentPatrolId != null).length;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Total',
              guards.length.toString(),
              Icons.people,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Online',
              onlineCount.toString(),
              Icons.circle,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'Offline',
              offlineCount.toString(),
              Icons.circle,
              Colors.red,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              'On Patrol',
              onPatrolCount.toString(),
              Icons.directions_walk,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty 
                ? 'No guards found matching "$_searchQuery"'
                : 'No guards found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuardsList(List<LiveGuardLocation> guards) {
    return ListView.builder(
      itemCount: guards.length,
      itemBuilder: (context, index) {
        final guard = guards[index];
        return _buildGuardCard(guard);
      },
    );
  }

  Widget _buildGuardCard(LiveGuardLocation guard) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (guard.status.toLowerCase()) {
      case 'online':
      case 'active':
        statusColor = Colors.green;
        statusIcon = Icons.circle;
        statusText = 'Online';
        break;
      case 'busy':
        statusColor = Colors.orange;
        statusIcon = Icons.circle;
        statusText = 'Busy';
        break;
      case 'offline':
        statusColor = Colors.red;
        statusIcon = Icons.circle;
        statusText = 'Offline';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = guard.status;
    }
    
    final timeSinceUpdate = DateTime.now().difference(guard.lastUpdate);
    final isStale = timeSinceUpdate.inMinutes > 5; // Consider data stale after 5 minutes
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                guard.guardName.split(' ').map((n) => n[0]).take(2).join().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                guard.guardName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isStale)
              Icon(
                Icons.warning,
                size: 16,
                color: Colors.orange.shade600,
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, size: 12, color: statusColor),
                const SizedBox(width: 4),
                Text(statusText),
                const Spacer(),
                Text(
                  _formatLastUpdate(guard.lastUpdate),
                  style: TextStyle(
                    fontSize: 12,
                    color: isStale ? Colors.orange.shade600 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (guard.currentPatrolId != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.directions_walk,
                    size: 12,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'On Patrol #${guard.currentPatrolId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 12,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${guard.latitude.toStringAsFixed(4)}, ${guard.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleGuardAction(value, guard),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'locate',
              child: Row(
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text('Locate on Map'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'contact',
              child: Row(
                children: [
                  Icon(Icons.message),
                  SizedBox(width: 8),
                  Text('Send Message'),
                ],
              ),
            ),
            if (guard.status.toLowerCase() == 'offline')
              const PopupMenuItem(
                value: 'ping',
                child: Row(
                  children: [
                    Icon(Icons.wifi_tethering),
                    SizedBox(width: 8),
                    Text('Ping Device'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'details',
              child: Row(
                children: [
                  Icon(Icons.info),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showGuardDetails(guard),
      ),
    );
  }

  List<LiveGuardLocation> _filterGuards(List<LiveGuardLocation> guards) {
    var filtered = guards;
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'online':
        filtered = filtered.where((g) => g.status.toLowerCase() == 'online').toList();
        break;
      case 'offline':
        filtered = filtered.where((g) => g.status.toLowerCase() == 'offline').toList();
        break;
      case 'on_patrol':
        filtered = filtered.where((g) => g.currentPatrolId != null).toList();
        break;
    }
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((g) => 
        g.guardName.toLowerCase().contains(_searchQuery)
      ).toList();
    }
    
    // Sort by status priority (online first, then by name)
    filtered.sort((a, b) {
      final statusPriority = {'online': 0, 'busy': 1, 'offline': 2};
      final aPriority = statusPriority[a.status.toLowerCase()] ?? 3;
      final bPriority = statusPriority[b.status.toLowerCase()] ?? 3;
      
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      
      return a.guardName.compareTo(b.guardName);
    });
    
    return filtered;
  }

  String _formatLastUpdate(DateTime lastUpdate) {
    final difference = DateTime.now().difference(lastUpdate);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleGuardAction(String action, LiveGuardLocation guard) {
    switch (action) {
      case 'locate':
        _locateGuardOnMap(guard);
        break;
      case 'contact':
        _sendMessageToGuard(guard);
        break;
      case 'ping':
        _pingGuardDevice(guard);
        break;
      case 'details':
        _showGuardDetails(guard);
        break;
    }
  }

  void _locateGuardOnMap(LiveGuardLocation guard) {
    // Placeholder - would integrate with map widget
    _showSnackBar('Locating ${guard.guardName} on map...');
  }

  void _sendMessageToGuard(LiveGuardLocation guard) {
    // Placeholder for messaging functionality
    _showSnackBar('Opening message composer for ${guard.guardName}...');
  }

  void _pingGuardDevice(LiveGuardLocation guard) {
    // Placeholder for device ping functionality
    _showSnackBar('Pinging ${guard.guardName}\'s device...');
  }

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
            _detailRow('Last Update', guard.lastUpdate.toString()),
            if (guard.currentPatrolId != null)
              _detailRow('Current Patrol', 'Patrol #${guard.currentPatrolId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (guard.status.toLowerCase() == 'offline')
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _pingGuardDevice(guard);
              },
              child: const Text('Ping Device'),
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

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}