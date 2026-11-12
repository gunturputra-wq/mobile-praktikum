import '../models/course.dart';
import '../services/course_data_source.dart';

class CourseRepository {
  final CourseDataSource dataSource;

  CourseRepository(this.dataSource);

  // GET: mengambil daftar course dengan penanganan error dan log detail
  Future<List<Course>> getCourses() async {
    try {
      final courses = await dataSource.getCourses();
      print('REPOSITORY: Berhasil memuat ${courses.length} course dari data source.');
      return courses;
    } catch (e, stackTrace) {
      print('================ ERROR DI REPOSITORY (getCourses) ================');
      print('Pesan Error: $e');
      print('Stack Trace: $stackTrace');
      print('==================================================================');
      // Mengembalikan list kosong agar UI tidak crash, namun error tercetak di console
      return [];
    }
  }

  // POST: membuat course baru
  Future<Course> createCourse(Course course) async {
    try {
      return await dataSource.createCourse(course);
    } catch (e) {
      print('ERROR DI REPOSITORY (createCourse): $e');
      rethrow;
    }
  }

  // PUT/PATCH: memperbarui course
  Future<void> updateCourse(int id, Course course) async {
    try {
      return await dataSource.updateCourse(id, course);
    } catch (e) {
      print('ERROR DI REPOSITORY (updateCourse): $e');
      rethrow;
    }
  }

  // DELETE: menghapus course
  Future<void> deleteCourse(int id) async {
    try {
      return await dataSource.deleteCourse(id);
    } catch (e) {
      print('ERROR DI REPOSITORY (deleteCourse): $e');
      rethrow;
    }
  }
}