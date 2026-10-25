import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  final Set<String> _favorites = <String>{};

  int get favoriteCount => _favorites.length;

  bool isFavorite(String id) => _favorites.contains(id);

  Future<List<Course>> getCourses() {
    return repository.getCourses();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }
}
