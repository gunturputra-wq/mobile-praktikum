import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase;

  CourseSupabaseService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  String? get _uid => supabase.auth.currentUser?.id;

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
    final payload = Map<String, dynamic>.from(course.toJson());
    if (_uid != null) {
      payload['owner_id'] = _uid;
    }

    final row = await supabase
        .from('courses')
        .insert(payload)
        .select()
        .single();

    return Course.fromJson(
      Map<String, dynamic>.from(row),
    );
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    final rows = await supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id)
        .select();

    if (rows.isEmpty) {
      throw Exception(
        'Ditolak RLS: Anda tidak memiliki izin untuk mengubah mata kuliah ini.',
      );
    }
  }

  @override
  Future<void> deleteCourse(int id) async {
    final rows = await supabase
        .from('courses')
        .delete()
        .eq('id', id)
        .select();

    if (rows.isEmpty) {
      throw Exception(
        'Ditolak RLS: Anda tidak memiliki izin untuk menghapus mata kuliah ini.',
      );
    }
  }
}