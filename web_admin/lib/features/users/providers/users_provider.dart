import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../shared/models/user.dart';
import '../../../shared/models/api_response.dart';
import '../../../shared/services/user_service.dart';

class UsersState {
  final List<User> users;
  final bool isLoading;
  final String? error;
  final PaginationInfo? pagination;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.error,
    this.pagination,
  });

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
    PaginationInfo? pagination,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pagination: pagination ?? this.pagination,
    );
  }

  // AsyncValue-like when method for UI compatibility
  T when<T>({
    required T Function(List<User> data) data,
    required T Function(Object error, StackTrace stackTrace) error,
    required T Function() loading,
  }) {
    if (isLoading) {
      return loading();
    } else if (this.error != null) {
      return error(this.error!, StackTrace.current);
    } else {
      return data(users);
    }
  }
}

class UsersNotifier extends StateNotifier<UsersState> {
  final UserService _userService;

  UsersNotifier(this._userService) : super(const UsersState()) {
    loadUsers();
  }

  Future<void> loadUsers({
    int page = 1,
    int perPage = 20,
    String? search,
    bool? isActive,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _userService.getUsers(
        page: page,
        perPage: perPage,
        search: search,
        isActive: isActive,
      );

      state = state.copyWith(
        users: response.data,
        pagination: response.pagination,
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

  Future<void> createUser(CreateUserRequest request) async {
    try {
      final newUser = await _userService.createUser(request);
      state = state.copyWith(
        users: [...state.users, newUser],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateUser(int id, UpdateUserRequest request) async {
    try {
      final updatedUser = await _userService.updateUser(id, request);
      final updatedUsers = state.users.map((user) {
        return user.id == id ? updatedUser : user;
      }).toList();

      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _userService.deleteUser(id);
      final updatedUsers = state.users.where((user) => user.id != id).toList();
      state = state.copyWith(users: updatedUsers);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final usersProvider = StateNotifierProvider<UsersNotifier, UsersState>((ref) {
  final userService = ref.watch(userServiceProvider);
  return UsersNotifier(userService);
});