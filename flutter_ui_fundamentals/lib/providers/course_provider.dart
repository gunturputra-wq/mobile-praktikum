import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  final Set<String> _favorites = <String>{};

  int get favoriteCount => _favorites.length;

  Set<String> get favoriteIds => Set.unmodifiable(_favorites);

  bool isFavorite(String code) => _favorites.contains(code);

  List<Course> favoriteCourses(List<Course> courses) {
    return courses
        .where((course) => _favorites.contains(course.code))
        .toList();
  }

  String _friendlyError(Object exception) {
    final details = exception.toString().toLowerCase();

    if (details.contains('socketexception') ||
        details.contains('failed host lookup') ||
        details.contains('failed to fetch') ||
        details.contains('clientexception') ||
        details.contains('network is unreachable') ||
        details.contains('connection refused') ||
        details.contains('connection reset')) {
      return 'Koneksi internet bermasalah. '
          'Periksa koneksi lalu tekan Coba Lagi.';
    }

    if (details.contains('404') || details.contains('not found')) {
      return 'Data atau endpoint tidak ditemukan (HTTP 404). '
          'Periksa konfigurasi layanan.';
    }

    if (details.contains('42501') ||
        details.contains('permission denied') ||
        details.contains('row-level security') ||
        details.contains('unauthorized') ||
        details.contains('403') ||
        details.contains('401')) {
      return 'Akses data ditolak. Periksa izin akses '
          'dan kebijakan keamanan Supabase.';
    }

    if (details.contains('23505') ||
        details.contains('duplicate key') ||
        details.contains('unique constraint')) {
      return 'Data duplikat. Gunakan nilai yang belum tersedia.';
    }

    if (details.contains('23502') ||
        details.contains('not-null constraint')) {
      return 'Ada kolom wajib yang belum diisi.';
    }

    if (details.contains('22p02') ||
        details.contains('invalid input syntax')) {
      return 'Format salah satu nilai tidak sesuai dengan '
          'tipe data yang diperlukan.';
    }

    if (exception is FormatException ||
        details.contains('typeerror') ||
        details.contains('type cast') ||
        details.contains('json')) {
      return 'Format data tidak sesuai. Periksa struktur '
          'data yang diterima.';
    }

    return 'Terjadi kesalahan saat memproses data. '
        'Silakan coba lagi.';
  }

  // HTTP GET: memuat daftar course.
  Future<void> loadCourses() async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await repository.getCourses();
      courses = result;
    } catch (e) {
      error = _friendlyError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Course>> getCourses() {
    return repository.getCourses();
  }

  // Favorit dikelola di dalam aplikasi.
  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }

  // HTTP POST: menambahkan course.
  Future<Course> createCourse(Course course) async {
    try {
      final createdCourse = await repository.createCourse(course);
      courses = await repository.getCourses();
      error = null;
      notifyListeners();
      return createdCourse;
    } catch (e) {
      error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  // HTTP PUT/PATCH: memperbarui course.
  Future<void> updateCourse(int id, Course updatedCourse) async {
    try {
      await repository.updateCourse(id, updatedCourse);
      courses = await repository.getCourses();
      error = null;
      notifyListeners();
    } catch (e) {
      error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }

  // HTTP DELETE: menghapus course.
  Future<void> deleteCourse(int id) async {
    final deletedCourses =
        courses.where((course) => course.id == id).toList();

    try {
      await repository.deleteCourse(id);

      _favorites.remove(id.toString());

      for (final course in deletedCourses) {
        _favorites.remove(course.code);
      }

      courses = await repository.getCourses();
      error = null;
      notifyListeners();
    } catch (e) {
      error = _friendlyError(e);
      notifyListeners();
      rethrow;
    }
  }
}
