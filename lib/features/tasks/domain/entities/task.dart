import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Timestamp
import 'package:uuid/uuid.dart';

// Enum to represent the status of a task
enum TaskStatus { todo, inProgress, done }

class Task {
  late String uuid;
  late String title;
  late TaskStatus status;
  late DateTime createdAt;
  late String projectId; // Foreign key to Project
  String? userId; // Nullable field to store the Firebase Auth User ID

  // Constructor now generates the UUID and requires projectId, userId is optional
  Task({
    required this.projectId,
    required this.title,
    this.status = TaskStatus.todo,
    this.userId, // Make userId optional in constructor
  }) : uuid = const Uuid().v4(),
       createdAt = DateTime.now();

  // Factory constructor for creating a new Task instance from a map.
  factory Task.fromJson(Map<String, dynamic> json) {
    final task =
        Task(
            projectId: json['projectId'] as String,
            title: json['title'] as String,
            // Handle enum deserialization carefully
            status: TaskStatus.values.firstWhere(
              (e) => e.toString() == json['status'],
              orElse:
                  () => TaskStatus.todo, // Default if status is invalid/missing
            ),
            // Handle nullable userId during deserialization
            userId: json['userId'] as String?,
          )
          ..uuid =
              json['uuid']
                  as String // Assign existing uuid
          // Convert Firestore Timestamp to DateTime
          ..createdAt = (json['createdAt'] as Timestamp).toDate();
    return task;
  }

  // Method for converting a Task instance into a map.
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'title': title,
    'status': status.toString(), // Store enum as string
    'createdAt': Timestamp.fromDate(createdAt), // Store as Firestore Timestamp
    'projectId': projectId,
    // Include userId only if it's not null
    if (userId != null) 'userId': userId,
  };
}
