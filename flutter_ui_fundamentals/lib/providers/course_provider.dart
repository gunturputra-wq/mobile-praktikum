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
          (course) => _favorites.contains(course.id?.toString() ?? course.code),
        )
        .toList();
  }

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

  void toggleFavorite(String code) {
    if (_favorites.contains(code)) {
      _favorites.remove(code);
    } else {
      _favorites.add(code);
    }

    notifyListeners();
  }

  
  Future<void> updateCourse(int id, Course updatedCourse) async {
    try {
      await repository.updateCourse(id, updatedCourse);

      // Ambil data terbaru dari server setelah update berhasil.
      courses = await repository.getCourses();

      error = null;
      notifyListeners();
    } catch (e) {
      error = 'Gagal memperbarui course: $e';
      notifyListeners();
      rethrow;
    }
  }

}
