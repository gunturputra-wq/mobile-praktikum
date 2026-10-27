
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
        .where(
          (course) =>
              _favorites.contains(course.code),
        )
        .toList();
  }

  // HTTP GET: mengambil daftar course
  Future<void> loadCourses() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      error = 'Gagal memuat data course: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Course>> getCourses() {
    return repository.getCourses();
  }

  // Mengubah status favorit
  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }

  // HTTP POST: menambahkan course baru
  Future<Course> createCourse(Course course) async {
    try {
      final createdCourse = await repository.createCourse(course);

      courses = await repository.getCourses();

      error = null;
      notifyListeners();

      return createdCourse;
    } catch (e) {
      error = 'Gagal menambahkan course: $e';
      notifyListeners();
      rethrow;
    }
  }
  // HTTP PUT: memperbarui course
  Future<void> updateCourse(int id, Course updatedCourse) async {
    try {
      await repository.updateCourse(id, updatedCourse);

      courses = await repository.getCourses();

      error = null;
      notifyListeners();
    } catch (e) {
      error = 'Gagal memperbarui course: $e';
      notifyListeners();
      rethrow;
    }
  }

  // HTTP DELETE: menghapus course
  Future<void> deleteCourse(int id) async {
    final deletedCourses = courses
        .where((course) => course.id == id)
        .toList();

    try {
      await repository.deleteCourse(id);

      // Hapus favorit berdasarkan ID dan kode course.
      _favorites.remove(id.toString());

      for (final course in deletedCourses) {
        _favorites.remove(course.code);
      }

      // Perbarui daftar course dari server.
      courses = await repository.getCourses();

      error = null;
      notifyListeners();
    } catch (e) {
      error = 'Gagal menghapus course: $e';
      notifyListeners();
      rethrow;
    }
  }
}


