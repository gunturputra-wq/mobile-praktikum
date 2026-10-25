
class Course {
  final int? id;
  final String code;
  final String title;
  final int credits;
  final String category;
  final String status;
  final String description;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    this.category = 'Umum',
    this.status = 'planned',
    this.description = '',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['id'];
    final dynamic rawCredits = json['credits'];

    return Course(
      id: rawId == null
          ? null
          : int.tryParse(rawId.toString()),
      code: json['code']?.toString() ?? '',
      title: json['title']?.toString() ??
          'Mata Kuliah Tanpa Nama',
      credits: rawCredits is num
          ? rawCredits.toInt()
          : int.tryParse(rawCredits?.toString() ?? '') ?? 0,
      category: json['category']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'planned',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'code': code,
      'title': title,
      'credits': credits,
      'category': category,
      'status': status,
      'description': description,
    };
  }
}
