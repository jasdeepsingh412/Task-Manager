import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/task_model.dart';
import '../data/task_service.dart';

final taskServiceProvider = Provider((ref) => TaskService());

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskService _taskService;
  final User? _user;

  String _searchQuery = "";

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _filterTasks();
  }

  List<Task> _allTasks = [];

  void _filterTasks() {
    if (_searchQuery.isEmpty) {
      state = AsyncValue.data(_allTasks);
    } else {
      final filtered = _allTasks.where((task) {
        return task.title.toLowerCase().contains(_searchQuery) ||
            task.description.toLowerCase().contains(_searchQuery);
      }).toList();

      state = AsyncValue.data(filtered);
    }
  }

  TaskNotifier(this._taskService, this._user)
      : super(const AsyncValue.loading()) {
    fetchTasks();
  }
  Future<void> updateTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _taskService.updateTask(user.uid, task);
    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading();

      if (_user == null) {
        state = const AsyncValue.data([]);
        return;
      }

      final tasks = await _taskService.fetchTasks(_user!.uid);
      _allTasks = tasks;
      _filterTasks();

      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(Task task) async {
    if (_user == null) return;

    await _taskService.addTask(_user!.uid, task);
    await fetchTasks();
  }


  Future<void> deleteTask(String taskId) async {
    if (_user == null) return;

    await _taskService.deleteTask(_user!.uid, taskId);
    await fetchTasks();
  }
}

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final taskProvider =
StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {

  final authUser = ref.watch(authStateProvider).value;

  final service = ref.watch(taskServiceProvider);

  return TaskNotifier(service, authUser);
});