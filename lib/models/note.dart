class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final bool isPinned;
  final String? categoryName;
  final List<String> tags;
  final bool isDeleted;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.isPinned = false,
    this.categoryName,
    this.tags = const [],
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(), // Chuyển đổi DateTime sang chuỗi ISO 8601
      'modifiedAt': modifiedAt.toIso8601String(),
      'isPinned': isPinned,
      'categoryName': categoryName,
      'tags': tags,
      'isDeleted': isDeleted,
    };
  }
}

