import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/patrol.dart';
import '../../../shared/services/patrol_service.dart';

/// Patrols state notifier for managing patrol data
class PatrolsNotifier extends StateNotifier<AsyncValue<List<Patrol>>> {
  PatrolsNotifier(this._patrolService) : super(const AsyncValue.loading());

  final PatrolService _patrolService;
  
  /// Load all patrols
  Future<void> loadPatrols({
    int? assignedTo,
    String? status,
    String? taskType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final patrols = await _patrolService.getPatrols(
        assignedTo: assignedTo,
        status: status,
        taskType: taskType,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      state = AsyncValue.data(patrols);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create a new patrol
  Future<bool> createPatrol(CreatePatrolRequest request) async {
    try {
      final newPatrol = await _patrolService.createPatrol(request);
      
      // Add to current state if loaded
      state.whenData((patrols) {
        state = AsyncValue.data([...patrols, newPatrol]);
      });
      
      return true;
    } catch (e) {
      // Handle error but don't update state
      return false;
    }
  }

  /// Update an existing patrol
  Future<bool> updatePatrol(int id, UpdatePatrolRequest request) async {
    try {
      final updatedPatrol = await _patrolService.updatePatrol(id, request);
      
      // Update in current state if loaded
      state.whenData((patrols) {
        final updatedPatrols = patrols.map((patrol) {
          return patrol.id == id ? updatedPatrol : patrol;
        }).toList();
        state = AsyncValue.data(updatedPatrols);
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get patrol by ID
  Future<Patrol?> getPatrolById(int id) async {
    try {
      return await _patrolService.getPatrolById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get patrols for a specific date
  List<Patrol> getPatrolsForDate(DateTime date) {
    return state.maybeWhen(
      data: (patrols) => patrols.where((patrol) {
        final patrolDate = patrol.scheduledStart;
        return patrolDate.year == date.year &&
               patrolDate.month == date.month &&
               patrolDate.day == date.day;
      }).toList(),
      orElse: () => [],
    );
  }

  /// Get patrols by status
  List<Patrol> getPatrolsByStatus(String status) {
    return state.maybeWhen(
      data: (patrols) => patrols.where((patrol) => 
        patrol.status.toLowerCase() == status.toLowerCase()
      ).toList(),
      orElse: () => [],
    );
  }

  /// Get patrol statistics
  Map<String, int> getPatrolStatistics() {
    return state.maybeWhen(
      data: (patrols) {
        final stats = <String, int>{
          'total': patrols.length,
          'assigned': 0,
          'in_progress': 0,
          'completed': 0,
          'overdue': 0,
        };

        final now = DateTime.now();
        
        for (final patrol in patrols) {
          switch (patrol.status.toLowerCase()) {
            case 'assigned':
              stats['assigned'] = stats['assigned']! + 1;
              break;
            case 'in_progress':
              stats['in_progress'] = stats['in_progress']! + 1;
              break;
            case 'completed':
              stats['completed'] = stats['completed']! + 1;
              break;
            default:
              break;
          }
          
          // Check for overdue patrols
          if (patrol.scheduledEnd.isBefore(now) && 
              patrol.status.toLowerCase() != 'completed') {
            stats['overdue'] = stats['overdue']! + 1;
          }
        }
        
        return stats;
      },
      orElse: () => {
        'total': 0,
        'assigned': 0,
        'in_progress': 0,
        'completed': 0,
        'overdue': 0,
      },
    );
  }

  /// Start a patrol
  Future<bool> startPatrol(int id) async {
    try {
      final updatedPatrol = await _patrolService.startPatrol(id);
      
      // Update in current state if loaded
      state.whenData((patrols) {
        final updatedPatrols = patrols.map((patrol) {
          return patrol.id == id ? updatedPatrol : patrol;
        }).toList();
        state = AsyncValue.data(updatedPatrols);
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Complete a patrol
  Future<bool> completePatrol(int id) async {
    try {
      final updatedPatrol = await _patrolService.completePatrol(id);
      
      // Update in current state if loaded
      state.whenData((patrols) {
        final updatedPatrols = patrols.map((patrol) {
          return patrol.id == id ? updatedPatrol : patrol;
        }).toList();
        state = AsyncValue.data(updatedPatrols);
      });
      
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Provider for patrols state
final patrolsProvider = StateNotifierProvider<PatrolsNotifier, AsyncValue<List<Patrol>>>((ref) {
  final patrolService = ref.watch(patrolServiceProvider);
  return PatrolsNotifier(patrolService);
});

/// Provider for patrol statistics
final patrolStatisticsProvider = Provider<Map<String, int>>((ref) {
  final patrolsNotifier = ref.watch(patrolsProvider.notifier);
  return patrolsNotifier.getPatrolStatistics();
});

/// Provider for patrols by date
final patrolsByDateProvider = Provider.family<List<Patrol>, DateTime>((ref, date) {
  final patrolsNotifier = ref.watch(patrolsProvider.notifier);
  return patrolsNotifier.getPatrolsForDate(date);
});

/// Provider for patrols by status
final patrolsByStatusProvider = Provider.family<List<Patrol>, String>((ref, status) {
  final patrolsNotifier = ref.watch(patrolsProvider.notifier);
  return patrolsNotifier.getPatrolsByStatus(status);
});