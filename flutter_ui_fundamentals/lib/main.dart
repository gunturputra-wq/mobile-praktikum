import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// IDENTITAS MAHASISWA
const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

// MODEL DATA COURSE
class Course {
  final String id;
  final String code;
  final String title;
  final int credits;
  final String category;
  final String status;
  final String description;
  bool isFavorite;

  Course({
    required this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.category,
    required this.status,
    required this.description,
    this.isFavorite = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String? ?? '0',
      code: json['code'] as String? ?? 'MOB00',
      title: json['title'] as String? ?? 'Tanpa Judul',
      credits: json['credits'] as int? ?? 0,
      category: json['category'] as String? ?? 'Umum',
      status: json['status'] as String? ?? 'planned',
      description: json['description'] as String? ?? 'Tidak ada deskripsi.',
    );
  }
}

// FUNGSI LOAD DATA JSON
Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString('assets/data/student_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MainResponsiveShell(),
    );
  }
}

// =============================================================================
// MAIN RESPONSIVE SHELL
// =============================================================================
class MainResponsiveShell extends StatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  State<MainResponsiveShell> createState() => _MainResponsiveShellState();
}

class _MainResponsiveShellState extends State<MainResponsiveShell> {
  int selectedIndex = 0;
  late Future<Map<String, dynamic>> dataFuture;
  List<Course> coursesList = [];
  bool isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    dataFuture = loadStudentData();
  }

  void _onDataLoaded(Map<String, dynamic> data) {
    if (!isDataLoaded) {
      final rawCourses = data['courses'] as List<dynamic>;
      coursesList = rawCourses.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
      isDataLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Gagal memuat data:\n${snapshot.error}', textAlign: TextAlign.center),
            ),
          );
        }

        _onDataLoaded(snapshot.data!);

        final pages = [
          HomePage(courses: coursesList),
          CoursesPage(
            courses: coursesList,
            onFavoriteToggle: (index) {
              setState(() {
                coursesList[index].isFavorite = !coursesList[index].isFavorite;
              });
            },
          ),
          const ProfilePage(),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final isExpanded = constraints.maxWidth >= 840;

            if (isExpanded) {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => selectedIndex = index);
                      },
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                        NavigationRailDestination(icon: Icon(Icons.school), label: Text('Courses')),
                        NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
                      ],
                    ),
                    const VerticalDivider(thickness: 1, width: 1),
                    Expanded(child: pages[selectedIndex]),
                  ],
                ),
              );
            }

            return Scaffold(
              body: pages[selectedIndex],
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  setState(() => selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
                  NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// =============================================================================
// REUSABLE WIDGET: STUDENT HEADER CARD
// =============================================================================
class StudentHeaderCard extends StatelessWidget {
  const StudentHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentId,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text('Pendidikan Teknik Informatika'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 1: HOME PAGE
// =============================================================================
class HomePage extends StatelessWidget {
  final List<Course> courses;
  const HomePage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final totalCourses = courses.length;
    final totalCredits = courses.fold<int>(0, (sum, item) => sum + item.credits);

    final skills = ['Flutter', 'Dart', 'Responsive UI', 'REST API', 'State Management', 'Git'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer - Home'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StudentHeaderCard(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Size: ${size.width.toStringAsFixed(0)} x ${size.height.toStringAsFixed(0)}'),
                      Text('Layout: ${size.width < 600 ? "Compact" : "Wide"}'),
                      Text('Ori: ${orientation.name}'),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Card(
                      color: Colors.blue.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.book, size: 28),
                            Text('$totalCourses', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const Text('Total Matkul'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: Card(
                      color: Colors.green.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.school, size: 28),
                            Text('$totalCredits', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const Text('SKS'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Keahlian / Skill Tags:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) => Chip(label: Text(skill))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 2: COURSES PAGE
// =============================================================================
class CoursesPage extends StatelessWidget {
  final List<Course> courses;
  final Function(int) onFavoriteToggle;

  const CoursesPage({
    super.key,
    required this.courses,
    required this.onFavoriteToggle,
  });

  int getColumns(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pembelajaran'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final cols = getColumns(constraints.maxWidth);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: cols == 1 ? 2.5 : 1.6,
              ),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];

                return InkWell(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(course: course),
                      ),
                    );

                    if (result == true && context.mounted) {
                      onFavoriteToggle(index);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${course.title} diperbarui di Favorit!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(course.title),
                        content: Text('Kategori: ${course.category}\nSKS: ${course.credits}\nKode: ${course.code}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Chip(
                                label: Text(
                                  course.code,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  course.isFavorite ? Icons.favorite : Icons.favorite_border,
                                  color: course.isFavorite ? Colors.red : Colors.grey,
                                ),
                                onPressed: () => onFavoriteToggle(index),
                              ),
                            ],
                          ),
                          Text(
                            course.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text('${course.credits} SKS • ${course.category}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// SCREEN 2 DETAIL: COURSE DETAIL PAGE
// =============================================================================
class CourseDetailPage extends StatefulWidget {
  final Course course;
  const CourseDetailPage({super.key, required this.course});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.course.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengembang: $studentName ($studentId)',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.course.code,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          label: Text(widget.course.status.toUpperCase()),
                          backgroundColor: widget.course.status == 'done'
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('Mata Kuliah: ${widget.course.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Bobot: ${widget.course.credits} SKS'),
                    Text('Kategori: ${widget.course.category}'),
                    const SizedBox(height: 16),
                    const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.course.description),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: isFav ? Colors.red.shade100 : Colors.blue.shade100,
              ),
              icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
              label: Text(isFav ? 'Hapus dari Favorit' : 'Tandai sebagai Favorit'),
              onPressed: () {
                setState(() => isFav = !isFav);
                Navigator.pop(context, true);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SCREEN 3: PROFILE & FEEDBACK FORM
// =============================================================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _nimController;
  final TextEditingController _feedbackController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: studentName);
    _nimController = TextEditingController(text: studentId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Kirim Ulasan?'),
          content: const Text('Apakah Anda yakin ingin mengirimkan ulasan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _isLoading = true);

                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    _feedbackController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ulasan berhasil dikirim! Terima kasih.')),
                    );
                  }
                });
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil & Ulasan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const StudentHeaderCard(),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Form Feedback Pembelajaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Mahasiswa',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _nimController,
                        decoration: const InputDecoration(
                          labelText: 'NIM',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'NIM wajib diisi' : null,
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _feedbackController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Komentar / Feedback',
                          hintText: 'Minimal 5 karakter...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Komentar tidak boleh kosong';
                          }
                          if (v.trim().length < 5) {
                            return 'Komentar minimal 5 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                              onPressed: _submitFeedback,
                              child: const Text('Kirim Ulasan'),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}