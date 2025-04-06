import 'package:uuid/uuid.dart';

class Project {
  late String uuid;
  late String name;
  String? userId; // Nullable field to store the Firebase Auth User ID

  // Constructor generates the UUID, userId is optional
  Project({required this.name, this.userId}) : uuid = const Uuid().v4();

  // Factory constructor for creating a new Project instance from a map.
  factory Project.fromJson(Map<String, dynamic> json) {
    final project = Project(
      name: json['name'] as String,
      // Handle nullable userId during deserialization
      userId: json['userId'] as String?,
    )..uuid = json['uuid'] as String; // Assign existing uuid
    return project;
  }

  // Method for converting a Project instance into a map.
  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'name': name,
    // Include userId only if it's not null
    if (userId != null) 'userId': userId,
  };

  // Note: We removed @immutable.
}
