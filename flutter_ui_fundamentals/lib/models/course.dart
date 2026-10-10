class Course {
  final String id;
  final String code;
  final String title;
  final int credits;
  final String category;
  final String status;
  final String description;

  const Course({
    required this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.category,
    required this.status,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    final String code = json['code']?.toString() ?? '';
    final dynamic rawCredits = json['credits'];

    int parsedCredits = 0;

    if (rawCredits is num) {
      parsedCredits = rawCredits.toInt();
    } else if (rawCredits != null) {
      parsedCredits = int.tryParse(rawCredits.toString()) ?? 0;
    }

    return Course(
      id: json['id']?.toString() ??
          (code.isNotEmpty
              ? code
              : 'course-${json['title'] ?? 'unknown'}'),
      code: code,
      title: json['title']?.toString() ?? 'Mata Kuliah Tanpa Nama',
      credits: parsedCredits,
      category: json['category']?.toString() ?? 'Umum',
      status: json['status']?.toString() ?? 'Belum dimulai',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'credits': credits,
      'category': category,
      'status': status,
      'description': description,
    };
  }
}
