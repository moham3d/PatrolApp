import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/site.dart';
import '../../../shared/services/site_service.dart';

class SitesState {
  final List<Site> sites;
  final bool isLoading;
  final String? error;
  final Site? selectedSite;

  const SitesState({
    this.sites = const [],
    this.isLoading = false,
    this.error,
    this.selectedSite,
  });

  SitesState copyWith({
    List<Site>? sites,
    bool? isLoading,
    String? error,
    Site? selectedSite,
  }) {
    return SitesState(
      sites: sites ?? this.sites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedSite: selectedSite ?? this.selectedSite,
    );
  }
}

class SitesNotifier extends StateNotifier<SitesState> {
  final SiteService _siteService;

  SitesNotifier(this._siteService) : super(const SitesState()) {
    loadSites();
  }

  Future<void> loadSites({bool? isActive, String? search}) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final sites = await _siteService.getSites(
        isActive: isActive,
        search: search,
      );
      state = state.copyWith(
        sites: sites,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        sites: [],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> selectSite(int siteId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final site = await _siteService.getSiteById(siteId);
      state = state.copyWith(
        selectedSite: site,
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

  Future<bool> createSite(CreateSiteRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final newSite = await _siteService.createSite(request);
      final updatedSites = [...state.sites, newSite];
      state = state.copyWith(
        sites: updatedSites,
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

  Future<bool> updateSite(int siteId, UpdateSiteRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final updatedSite = await _siteService.updateSite(siteId, request);
      final updatedSites = state.sites.map((site) {
        return site.id == siteId ? updatedSite : site;
      }).toList();
      
      state = state.copyWith(
        sites: updatedSites,
        selectedSite: state.selectedSite?.id == siteId ? updatedSite : state.selectedSite,
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

  void clearSelectedSite() {
    state = state.copyWith(selectedSite: null);
  }
}

final sitesProvider = StateNotifierProvider<SitesNotifier, SitesState>((ref) {
  final siteService = ref.watch(siteServiceProvider);
  return SitesNotifier(siteService);
});