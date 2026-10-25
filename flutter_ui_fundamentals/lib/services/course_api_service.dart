
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // HTTP GET: mengambil daftar course
  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil course. Status: ${response.statusCode}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data
        .map(
          (item) => Course.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  // HTTP POST: membuat course baru
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/courses'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    throw Exception(
      'Gagal membuat course. Status: ${response.statusCode}',
    );
  }

  // HTTP PUT: memperbarui course yang sudah ada
  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/courses/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course. Status: ${response.statusCode}',
      );
    }
  }
}
