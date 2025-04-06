import 'dart:async'; // For Stream

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/presentation/providers/auth_providers.dart'; // Import auth providers
import 'package:planner/features/tasks/domain/entities/task.dart' as entity;

// Provider for the TaskRepository instance
// Depends on the currentUserIdProvider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  // Get the current user ID (can be null for anonymous)
  final userId = ref.watch(currentUserIdProvider);
  // Pass userId and Firestore instance to the repository
  return TaskRepository(FirebaseFirestore.instance, userId);
});

class TaskRepository {
  final FirebaseFirestore _firestore;
  final String? _userId; // Store the current user ID (nullable)

  // Constructor accepts Firestore instance and userId
  TaskRepository(this._firestore, this._userId);

  // Helper to get the user's base collection reference (needed for project path)
  DocumentReference<Map<String, dynamic>> _userDocRef() {
    if (_userId == null) {
      throw StateError('User is not logged in. Cannot access user document.');
    }
    return _firestore.collection('users').doc(_userId);
  }

  // Helper to get the tasks subcollection reference for a specific project
  CollectionReference<entity.Task> _tasksRef(String projectId) {
    if (_userId == null) {
      // This should ideally not be reached if UI prevents actions for anonymous users
      throw StateError(
        'User is not logged in. Cannot access tasks subcollection.',
      );
    }
    return _userDocRef()
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .withConverter<entity.Task>(
          fromFirestore:
              (snapshot, _) => entity.Task.fromJson(snapshot.data()!),
          toFirestore: (task, _) => task.toJson(),
        );
  }

  // --- Repository Methods (Firestore Implementation) ---

  // Note: watchAllTasks across all projects might be inefficient.
  // Consider if this is truly needed or if tasks should always be watched per project.
  // If needed, it would require a CollectionGroup query. For now, returning empty.
  Stream<List<entity.Task>> watchAllTasks() {
    if (_userId == null) {
      return Stream.value([]); // No tasks for anonymous users
    }
    // TODO: Implement with CollectionGroup query if cross-project task watching is required.
    print(
      "Warning: watchAllTasks across all projects is not implemented efficiently yet.",
    );
    return Stream.value([]);
  }

  // Similar caution for getAllTasks across all projects.
  Future<List<entity.Task>> getAllTasks() async {
    if (_userId == null) {
      return []; // No tasks for anonymous users
    }
    // TODO: Implement with CollectionGroup query if cross-project task fetching is required.
    print(
      "Warning: getAllTasks across all projects is not implemented efficiently yet.",
    );
    return [];
  }

  Stream<List<entity.Task>> watchTasksForProjectUuid(String projectUuid) {
    if (_userId == null) {
      return Stream.value([]); // No tasks for anonymous users
    }
    try {
      return _tasksRef(projectUuid)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print("Error watching tasks for project $projectUuid: $error");
            return <entity.Task>[];
          });
    } catch (e) {
      print("Error getting tasks collection reference for $projectUuid: $e");
      return Stream.value([]);
    }
  }

  Future<List<entity.Task>> getTasksForProjectUuid(String projectUuid) async {
    if (_userId == null) {
      return []; // No tasks for anonymous users
    }
    try {
      final snapshot = await _tasksRef(projectUuid).get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error getting tasks for project $projectUuid: $e");
      return [];
    }
  }

  Future<entity.Task?> getTaskByUuid(
    String projectUuid,
    String taskUuid,
  ) async {
    if (_userId == null) {
      return null; // No tasks for anonymous users
    }
    try {
      final docSnapshot = await _tasksRef(projectUuid).doc(taskUuid).get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      print(
        "Error getting task by UUID ($taskUuid) in project ($projectUuid): $e",
      );
      return null;
    }
  }

  Future<void> addTask(entity.Task task) async {
    if (_userId == null) {
      print("Cannot add task: User is not logged in.");
      return; // Or throw error
    }
    if (task.projectId.isEmpty) {
      print("Cannot add task: ProjectId is missing.");
      return; // Or throw error
    }
    try {
      // Ensure the task entity has the correct userId before saving
      task.userId = _userId;
      await _tasksRef(task.projectId).doc(task.uuid).set(task);
    } catch (e) {
      print("Error adding task to project ${task.projectId}: $e");
      // Rethrow or handle as needed
    }
  }

  Future<void> updateTask(entity.Task task) async {
    if (_userId == null) {
      print("Cannot update task: User is not logged in.");
      return; // Or throw error
    }
    if (task.projectId.isEmpty) {
      print("Cannot update task: ProjectId is missing.");
      return; // Or throw error
    }
    try {
      // Ensure the task entity has the correct userId before saving
      task.userId = _userId;
      await _tasksRef(task.projectId).doc(task.uuid).update(task.toJson());
    } catch (e) {
      print(
        "Error updating task ${task.uuid} in project ${task.projectId}: $e",
      );
      // Rethrow or handle as needed
    }
  }

  Future<bool> deleteTaskByUuid(String projectUuid, String taskUuid) async {
    if (_userId == null) {
      print("Cannot delete task: User is not logged in.");
      return false;
    }
    if (projectUuid.isEmpty) {
      print("Cannot delete task: ProjectId is missing.");
      return false;
    }
    try {
      await _tasksRef(projectUuid).doc(taskUuid).delete();
      return true;
    } catch (e) {
      print("Error deleting task $taskUuid in project $projectUuid: $e");
      return false;
    }
  }

  // Note: deleteTasksForProjectUuid is removed. Deletion is handled by ProjectRepository.
  // Note: Migration logic (`migrateAnonymousData`) is removed as per plan (deferred).
}
