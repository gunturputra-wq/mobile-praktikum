
import '../models/course.dart';
import '../services/course_data_source.dart';

class CourseRepository {
  final CourseDataSource dataSource;

  CourseRepository(this.dataSource);

  // GET: mengambil daftar course
  Future<List<Course>> getCourses() {
    return dataSource.getCourses();
  }

  // POST: membuat course baru
  Future<Course> createCourse(Course course) {
    return dataSource.createCourse(course);
  }

  // PUT/PATCH: memperbarui course
  Future<void> updateCourse(int id, Course course) {
    return dataSource.updateCourse(id, course);
  }

  // DELETE: menghapus course
  Future<void> deleteCourse(int id) {
    return dataSource.deleteCourse(id);
  }
}
