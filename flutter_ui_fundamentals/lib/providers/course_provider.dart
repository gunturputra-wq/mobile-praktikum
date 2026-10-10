
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  final Set<String> _favorites = <String>{};

  int get favoriteCount => _favorites.length;

  Set<String> get favoriteIds => Set.unmodifiable(_favorites);

  bool isFavorite(String code) => _favorites.contains(code);

  List<Course> favoriteCourses(List<Course> courses) {
    return courses
        .where((course) => _favorites.contains(course.id))
        .toList();
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
}