import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course.dart';

class CourseService {
  Future<List<Course>> loadCourses() async {
    final String jsonString = await rootBundle.loadString(
      'assets/data/student_data.json',
    );

    final dynamic decoded = jsonDecode(jsonString);

    List<dynamic> jsonList;

    if (decoded is List) {
      jsonList = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['courses'] is List) {
      jsonList = decoded['courses'] as List<dynamic>;
    } else {
      throw const FormatException(
        'Format JSON harus berupa list atau object dengan key courses.',
      );
    }

    return jsonList.map<Course>((dynamic item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Setiap mata kuliah harus berupa object JSON.',
        );
      }

      return Course.fromJson(item);
    }).toList();
  }
}
