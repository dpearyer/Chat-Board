class Task {
  String id;
  String name;
  bool isCompleted;

  Task({required this.id, required this.name, required this.isCompleted});

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      isCompleted: map['isCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}
