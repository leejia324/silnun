class Review {
  const Review({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final String content;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as int,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
