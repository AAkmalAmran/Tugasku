import 'package:flutter/foundation.dart';

import '../models/tugas.dart';
import '../services/api_service.dart';

/// Shared task state for Hari Ini, Tugas, Detail, and Profil.
/// Created ONCE in RootNavigation (Member 5) and passed to tabs
/// through constructors.
class TasksStore extends ChangeNotifier {
  final ApiService api;

  late Future<List<Tugas>> _future;

  /// "Done" status changed on the client (there is no update endpoint).
  /// Re-applied after every reload so ticks are not lost (risk R3).
  final Map<int, bool> _doneOverrides = {};

  TasksStore({required this.api}) {
    _future = _fetch();
  }

  /// Use this in FutureBuilder(future: store.tasks, ...).
  Future<List<Tugas>> get tasks => _future;

  /// async wrapper: turns synchronous throws (e.g. a stub's
  /// UnimplementedError) into a failed Future, so FutureBuilder shows
  /// the error state instead of crashing.
  Future<List<Tugas>> _fetch() async {
    final list = await api.fetchTasks();
    return _applyOverrides(list);
  }

  List<Tugas> _applyOverrides(List<Tugas> list) {
    return [
      for (final t in list)
        _doneOverrides.containsKey(t.id)
            ? t.copyWith(selesai: _doneOverrides[t.id])
            : t,
    ];
  }

  /// Reload from the server (pull-to-refresh and "Coba lagi").
  /// Reassigning the Future makes FutureBuilder show Loading again.
  void load() {
    _future = _fetch();
    notifyListeners();
  }

  /// Add a task returned by the server (the form result) to the visible
  /// list immediately, without waiting for a reload.
  void addTask(Tugas task) {
    _future = _future.then((list) => [...list, task]);
    notifyListeners();
  }

  /// Mark a task done / not done. Used by the checkbox (Member 2)
  /// and the Detail page (Member 3).
  void setDone(int id, bool done) {
    _doneOverrides[id] = done;
    _future = _future.then(_applyOverrides);
    notifyListeners();
  }

  /// Delete task from server and remove it from store.
  Future<void> deleteTask(int id) async {
    await api.deleteTask(id);
    _doneOverrides.remove(id);
    _future = _future.then((list) => list.where((t) => t.id != id).toList());
    notifyListeners();
  }
}