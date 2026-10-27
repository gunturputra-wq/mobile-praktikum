import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase;

  CourseSupabaseService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return data
        .map<Course>(
          (item) => Course.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(
      Map<String, dynamic>.from(row),
    );
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    throw UnimplementedError(
      'Update course belum diimplementasikan.',
    );
  }

  @override
  Future<void> deleteCourse(int id) async {
    throw UnimplementedError(
      'Delete course belum diimplementasikan.',
    );
  }
}
