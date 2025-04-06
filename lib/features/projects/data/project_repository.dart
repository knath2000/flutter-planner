import 'dart:async'; // For Stream

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planner/features/auth/presentation/providers/auth_providers.dart'; // Import auth providers
import 'package:planner/features/projects/domain/entities/project.dart'
    as entity;
// Import Task entity for deletion logic (consider moving deletion logic later)
import 'package:planner/features/tasks/domain/entities/task.dart'
    as task_entity;

// Provider for the ProjectRepository instance
// Depends on the currentUserIdProvider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  // Get the current user ID (can be null for anonymous)
  final userId = ref.watch(currentUserIdProvider);
  // Pass userId and Firestore instance to the repository
  return ProjectRepository(FirebaseFirestore.instance, userId);
});

class ProjectRepository {
  final FirebaseFirestore _firestore;
  final String? _userId; // Store the current user ID (nullable)

  // Constructor accepts Firestore instance and userId
  ProjectRepository(this._firestore, this._userId);

  // Helper to get the user's projects collection reference
  CollectionReference<entity.Project> _projectsRef() {
    if (_userId == null) {
      // This should ideally not be reached if UI prevents actions for anonymous users
      // Or, handle anonymous data in a separate collection if needed later.
      throw StateError(
        'User is not logged in. Cannot access projects collection.',
      );
    }
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('projects')
        .withConverter<entity.Project>(
          fromFirestore:
              (snapshot, _) => entity.Project.fromJson(snapshot.data()!),
          toFirestore: (project, _) => project.toJson(),
        );
  }

  // Helper to get the tasks subcollection for a specific project
  CollectionReference<task_entity.Task> _tasksRef(String projectId) {
    if (_userId == null) {
      throw StateError(
        'User is not logged in. Cannot access tasks subcollection.',
      );
    }
    return _projectsRef()
        .doc(projectId)
        .collection('tasks')
        .withConverter<task_entity.Task>(
          fromFirestore:
              (snapshot, _) => task_entity.Task.fromJson(snapshot.data()!),
          toFirestore: (task, _) => task.toJson(),
        );
  }

  // --- Repository Methods (Firestore Implementation) ---

  Stream<List<entity.Project>> watchProjects() {
    if (_userId == null) {
      return Stream.value([]); // No projects for anonymous users
    }
    try {
      return _projectsRef()
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList())
          .handleError((error) {
            print("Error watching projects: $error");
            // Optionally return an empty list or rethrow a specific error type
            return <entity.Project>[];
          });
    } catch (e) {
      print("Error getting projects collection reference: $e");
      return Stream.value([]);
    }
  }

  Future<List<entity.Project>> getAllProjects() async {
    if (_userId == null) {
      return []; // No projects for anonymous users
    }
    try {
      final snapshot = await _projectsRef().get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error getting all projects: $e");
      return [];
    }
  }

  Future<entity.Project?> getProjectByUuid(String uuid) async {
    if (_userId == null) {
      return null; // No projects for anonymous users
    }
    try {
      final docSnapshot = await _projectsRef().doc(uuid).get();
      return docSnapshot.exists ? docSnapshot.data() : null;
    } catch (e) {
      print("Error getting project by UUID ($uuid): $e");
      return null;
    }
  }

  Future<void> addProject(entity.Project project) async {
    if (_userId == null) {
      print("Cannot add project: User is not logged in.");
      return; // Or throw error
    }
    try {
      // Ensure the project entity has the correct userId before saving
      project.userId = _userId;
      await _projectsRef().doc(project.uuid).set(project);
    } catch (e) {
      print("Error adding project: $e");
      // Rethrow or handle as needed
    }
  }

  Future<void> updateProject(entity.Project project) async {
    if (_userId == null) {
      print("Cannot update project: User is not logged in.");
      return; // Or throw error
    }
    try {
      // Ensure the project entity has the correct userId before saving
      project.userId = _userId;
      await _projectsRef().doc(project.uuid).update(project.toJson());
    } catch (e) {
      print("Error updating project (${project.uuid}): $e");
      // Rethrow or handle as needed
    }
  }

  Future<bool> deleteProjectByUuid(String uuid) async {
    if (_userId == null) {
      print("Cannot delete project: User is not logged in.");
      return false;
    }
    try {
      // 1. Delete associated tasks in the subcollection
      final tasksQuerySnapshot = await _tasksRef(uuid).get();
      final WriteBatch batch = _firestore.batch();
      for (final doc in tasksQuerySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit(); // Commit task deletions

      // 2. Delete the project document itself
      await _projectsRef().doc(uuid).delete();
      return true;
    } catch (e) {
      print("Error deleting project ($uuid) and its tasks: $e");
      return false;
    }
  }

  // Note: Migration logic (`migrateAnonymousData`) is removed as per plan (deferred).
  // If needed later, it would involve reading from a potential anonymous store
  // and writing to the logged-in user's Firestore path.
}
