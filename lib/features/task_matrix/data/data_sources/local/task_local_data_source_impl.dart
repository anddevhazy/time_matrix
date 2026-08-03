import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/task_model.dart';
import 'task_local_data_source.dart';

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  TaskLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'time_matrix.tasks';

  @override
  Future<List<TaskModel>> getTasks() async {
    final raw = _prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTasks(List<TaskModel> tasks) async {
    final encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}
