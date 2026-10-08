import 'package:flutter/material.dart';

const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ResponsiveShell(),
    );
  }
}

// Data JSON / Collection Statik (Minimal 5 Item)
final List<Map<String, dynamic>> initialCourses = [
  {
    'code': 'MOB01',
    'title': 'Git & GitHub Fundamentals',
    'category': 'Version Control',
    'credits': 2,
    'description': 'Mempelajari pengelolaan repositori, commit, branching, dan kolaborasi tim.',
    'isFavorite': false,
  },
  {
    'code': 'MOB02',
    'title': 'Dart Essentials',
    'category': 'Programming',
    'credits': 2,
    'description': 'Penguasaan sintaks Dart, control flow, Async/Await, dan OOP.',
    'isFavorite': false,
  },
  {
    'code': 'MOB03',
    'title': 'Flutter UI Design',
    'category': 'Mobile Dev',
    'credits': 3,
    'description': 'Membangun antarmuka modern menggunakan Stateless & Stateful Widget.',
    'isFavorite': false,
  },
  {
    'code': 'MOB04',
    'title': 'Adaptive & Responsive Layout',
    'category': 'Mobile Dev',
    'credits': 3,
    'description': 'Teknik LayoutBuilder, MediaQuery, dan Flex untuk berbagai ukuran layar.',
    'isFavorite': false,
  },
  {
    'code': 'MOB05',
    'title': 'State Management Pattern',
    'category': 'Architecture',
    'credits': 3,
    'description': 'Penerapan pengelolaan state aplikasi menggunakan Provider/SetState.',
    'isFavorite': false,
  },
];

// 1. ResponsiveShell (Navigasi Adaptif: NavigationBar vs NavigationRail)
class ResponsiveShell extends StatefulWidget {
  const ResponsiveShell({super.key});

  @override
  State<ResponsiveShell> createState() => _ResponsiveShellState();
}

class _ResponsiveShellState extends State<ResponsiveShell> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> courses = List.from(initialCourses);

  void _toggleFavorite(int index) {
    setState(() {
      courses[index]['isFavorite'] = !courses[index]['isFavorite'];
    });
    
    // SnackBar Feedback saat ubah state favorit
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          courses[index]['isFavorite'] 
              ? '${courses[index]['title']} ditambahkan ke Favorit' 
              : '${courses[index]['title']} dihapus dari Favorit'
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= 600;

        final List<Widget> pages = [
          HomePage(courses: courses),
          CoursesPage(
            courses: courses, 
            onToggleFavorite: _toggleFavorite, 
            isExpanded: isExpanded,
          ),
          const ProfilePage(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Course Explorer'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Row(
            children: [
              // NavigationRail untuk Layar Expanded (Desktop/Tablet)
              if (isExpanded)
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.book), label: Text('Courses')),
                    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
                  ],
                ),
              if (isExpanded) const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: pages[_selectedIndex]),
            ],
          ),
          // NavigationBar untuk Layar Compact/Medium (HP)
          bottomNavigationBar: !isExpanded
              ? NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) => setState(() => _selectedIndex = index),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.book), label: 'Courses'),
                    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
                  ],
                )
              : null,
        );
      },
    );
  }
}

// 2. HomePage
class HomePage extends StatelessWidget {
  final List<Map<String, dynamic>> courses;
  const HomePage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final favCount = courses.where((c) => c['isFavorite'] == true).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reusable Widget 1: StudentCard
          const StudentCard(),
          const SizedBox(height: 16),
          Card(
            color: Colors.indigo.shade50,
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber, size: 36),
              title: const Text('Kursus Favorit', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$favCount kursus disukai dari total ${courses.length} kursus'),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. CoursesPage (Compact = List; Expanded = Master-Detail)
class CoursesPage extends StatefulWidget {
  final List<Map<String, dynamic>> courses;
  final Function(int) onToggleFavorite;
  final bool isExpanded;

  const CoursesPage({
    super.key, 
    required this.courses, 
    required this.onToggleFavorite,
    required this.isExpanded,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  int _selectedCourseIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Mode Expanded: Master-Detail Layout dalam 1 layar
    if (widget.isExpanded) {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: widget.courses.length,
              itemBuilder: (context, index) {
                final course = widget.courses[index];
                return ListTile(
                  selected: _selectedCourseIndex == index,
                  title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${course['code']} • ${course['credits']} SKS'),
                  trailing: IconButton(
                    icon: Icon(
                      course['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                      color: course['isFavorite'] ? Colors.red : null,
                    ),
                    onPressed: () => widget.onToggleFavorite(index),
                  ),
                  onTap: () => setState(() => _selectedCourseIndex = index),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 3,
            child: CourseDetailView(
              course: widget.courses[_selectedCourseIndex],
              onFavoriteToggle: () => widget.onToggleFavorite(_selectedCourseIndex),
            ),
          ),
        ],
      );
    }

    // Mode Compact: Single Column List (Pindah Halaman via Navigator.push)
    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: widget.courses.length,
      itemBuilder: (context, index) {
        final course = widget.courses[index];
        return Card(
          child: ListTile(
            title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${course['category']} • ${course['credits']} SKS'),
            trailing: IconButton(
              icon: Icon(
                course['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                color: course['isFavorite'] ? Colors.red : null,
              ),
              onPressed: () => widget.onToggleFavorite(index),
            ),
            onTap: () {
              // Passing Data lewat Constructor
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseDetailPage(
                    course: course,
                    onFavoriteToggle: () => widget.onToggleFavorite(index),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// Detail Page untuk Screen Compact (HP)
class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onFavoriteToggle;

  const CourseDetailPage({super.key, required this.course, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course['code'])),
      body: CourseDetailView(course: course, onFavoriteToggle: onFavoriteToggle),
    );
  }
}

// Reusable Widget 2: CourseDetailView (Digunakan di Master-Detail dan Detail Page)
class CourseDetailView extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onFavoriteToggle;

  const CourseDetailView({super.key, required this.course, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  course['title'], 
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: Icon(
                  course['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                  color: course['isFavorite'] ? Colors.red : null,
                  size: 28,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
          Chip(label: Text(course['category'])),
          const SizedBox(height: 12),
          Text('Bobot: ${course['credits']} SKS', style: const TextStyle(fontSize: 16)),
          const Divider(height: 24),
          const Text('Deskripsi Kursus:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(course['description'], style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}

// 4. ProfilePage & Form Feedback dengan Validasi & Dialog
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      // Dialog Konfirmasi/Informasi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Feedback Terkirim'),
          content: Text('Terima kasih atas masukan Anda!\n\nPengirim: $studentName ($studentId)'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _feedbackController.clear();
              },
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StudentCard(),
            const SizedBox(height: 20),
            const Text('Form Feedback Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Kritik & Saran',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mohon isi feedback terlebih dahulu';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text('Kirim Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Widget 1 (Definisi): StudentCard
class StudentCard extends StatelessWidget {
  const StudentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 26,
              child: Icon(Icons.person, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(studentName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('NIM: $studentId'),
                  Text('Pendidikan Teknik Informatika'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}