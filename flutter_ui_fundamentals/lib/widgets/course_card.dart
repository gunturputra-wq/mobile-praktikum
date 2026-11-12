class Course {
  final dynamic id;
  final String? ownerId;
  final String code;
  final String title;
  final int credits;
  final String category;
  final String status;
  final String description;

  const Course({
    this.id,
    this.ownerId,
    required this.code,
    required this.title,
    required this.credits,
    required this.category,
    required this.status,
    this.description = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      ownerId: json['owner_id'] as String?,
      code: (json['code'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      credits: (json['credits'] ?? 0) as int,
      category: (json['category'] ?? '') as String,
      status: (json['status'] ?? 'planned') as String,
      description: (json['description'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ownerId != null) 'owner_id': ownerId,
      'code': code,
      'title': title,
      'credits': credits,
      'category': category,
      'status': status,
      'description': description,
    };
  }
}