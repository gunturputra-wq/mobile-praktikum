
import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService apiService;

  CourseRepository(this.apiService);

  // HTTP GET: mengambil daftar course
  Future<List<Course>> getCourses() {
    return apiService.getCourses();
  }

  // HTTP POST: membuat course baru
  Future<Course> createCourse(Course course) {
    return apiService.createCourse(course);
  }

  // HTTP PUT: memperbarui course
  Future<void> updateCourse(int id, Course course) {
    return apiService.updateCourse(id, course);
  }

  // HTTP DELETE: menghapus course
  Future<void> deleteCourse(int id) {
    return apiService.deleteCourse(id);
  }
}
