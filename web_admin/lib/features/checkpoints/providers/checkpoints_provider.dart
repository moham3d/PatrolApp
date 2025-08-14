import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../shared/models/checkpoint.dart';
import '../../../shared/services/checkpoint_service.dart';
import '../../../core/utils/api_exceptions.dart';

class CheckpointsState {
  final List<Checkpoint> checkpoints;
  final bool isLoading;
  final String? error;
  final Checkpoint? selectedCheckpoint;
  final int? filterSiteId;
  final bool? filterIsActive;

  const CheckpointsState({
    this.checkpoints = const [],
    this.isLoading = false,
    this.error,
    this.selectedCheckpoint,
    this.filterSiteId,
    this.filterIsActive,
  });

  CheckpointsState copyWith({
    List<Checkpoint>? checkpoints,
    bool? isLoading,
    String? error,
    Checkpoint? selectedCheckpoint,
    int? filterSiteId,
    bool? filterIsActive,
  }) {
    return CheckpointsState(
      checkpoints: checkpoints ?? this.checkpoints,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCheckpoint: selectedCheckpoint ?? this.selectedCheckpoint,
      filterSiteId: filterSiteId ?? this.filterSiteId,
      filterIsActive: filterIsActive ?? this.filterIsActive,
    );
  }
}

class CheckpointsNotifier extends StateNotifier<CheckpointsState> {
  final CheckpointService _checkpointService;

  CheckpointsNotifier(this._checkpointService) : super(const CheckpointsState()) {
    loadCheckpoints();
  }

  Future<void> loadCheckpoints({int? siteId, bool? isActive}) async {
    state = state.copyWith(
      isLoading: true, 
      error: null,
      filterSiteId: siteId,
      filterIsActive: isActive,
    );
    
    try {
      final checkpoints = await _checkpointService.getCheckpoints(
        siteId: siteId,
        isActive: isActive,
      );
      state = state.copyWith(
        checkpoints: checkpoints,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        checkpoints: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectCheckpoint(int checkpointId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final checkpoint = await _checkpointService.getCheckpointById(checkpointId);
      state = state.copyWith(
        selectedCheckpoint: checkpoint,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createCheckpoint(CreateCheckpointRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newCheckpoint = await _checkpointService.createCheckpoint(request);
      final updatedCheckpoints = [...state.checkpoints, newCheckpoint];
      state = state.copyWith(
        checkpoints: updatedCheckpoints,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateCheckpoint(int checkpointId, UpdateCheckpointRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedCheckpoint = await _checkpointService.updateCheckpoint(checkpointId, request);
      final updatedCheckpoints = state.checkpoints.map((checkpoint) {
        return checkpoint.id == checkpointId ? updatedCheckpoint : checkpoint;
      }).toList();
      
      state = state.copyWith(
        checkpoints: updatedCheckpoints,
        selectedCheckpoint: state.selectedCheckpoint?.id == checkpointId 
            ? updatedCheckpoint 
            : state.selectedCheckpoint,
        isLoading: false,
        error: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearSelectedCheckpoint() {
    state = state.copyWith(selectedCheckpoint: null);
  }

  void setFilters({int? siteId, bool? isActive}) {
    loadCheckpoints(siteId: siteId, isActive: isActive);
  }
}

final checkpointsProvider = StateNotifierProvider<CheckpointsNotifier, CheckpointsState>((ref) {
  final checkpointService = ref.watch(checkpointServiceProvider);
  return CheckpointsNotifier(checkpointService);
});