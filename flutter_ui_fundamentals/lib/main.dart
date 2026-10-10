import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/course.dart';

const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseState(CourseRepository(CourseService())),
      child: const CourseExplorerApp(),
    ),
  );
}

// STATE FAVORIT DAN AKSES DATA MELALUI REPOSITORY
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

// APLIKASI UTAMA
class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FB),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8EAF2)),
          ),
        ),
      ),
      home: const MainResponsiveShell(),
    );
  }
}

// NAVIGASI RESPONSIF DAN PEMUATAN DATA
class MainResponsiveShell extends StatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  State<MainResponsiveShell> createState() => _MainResponsiveShellState();
}

class _MainResponsiveShellState extends State<MainResponsiveShell> {
  int selectedIndex = 0;

  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  late Future<List<Course>> coursesFuture;

  @override
  void initState() {
    super.initState();
    coursesFuture = context.read<CourseState>().getCourses();
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.school_rounded, color: Color(0xFF4F46E5)),
            SizedBox(width: 10),
            Text(
              'Course Explorer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Consumer<CourseState>(
                builder: (context, state, child) {
                  return Badge(
                    isLabelVisible: state.favoriteCount > 0,
                    label: Text('${state.favoriteCount}'),
                    child: const Icon(Icons.favorite_rounded),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Course>>(
        future: coursesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Data mata kuliah gagal dimuat.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          coursesFuture = context
                              .read<CourseState>()
                              .getCourses();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Course> courses = snapshot.data ?? <Course>[];

          final List<Widget> pages = [
            HomePage(
              courses: courses,
              counter: counter,
              onNavigate: (index) {
                setState(() => selectedIndex = index);
              },
            ),
            CoursesPage(courses: courses),
            ProfilePage(courses: courses),
          ];

          return Row(
            children: [
              if (isWide)
                NavigationRail(
                  selectedIndex: selectedIndex,
                  labelType: NavigationRailLabelType.all,
                  onDestinationSelected: (index) {
                    setState(() => selectedIndex = index);
                  },
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book),
                      label: Text('Mata Kuliah'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                  ],
                ),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: pages),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) {
                setState(() => selectedIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book),
                  label: 'Mata Kuliah',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
            ),
    );
  }
}

// DASHBOARD
class HomePage extends StatelessWidget {
  final List<Course> courses;
  final ValueNotifier<int> counter;
  final ValueChanged<int> onNavigate;

  const HomePage({
    super.key,
    required this.courses,
    required this.counter,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final int favoriteCount = context.watch<CourseState>().favoriteCount;

    final int totalCredits = courses.fold<int>(
      0,
      (int sum, Course course) => sum + course.credits,
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.waving_hand_rounded, color: Colors.white, size: 34),
              SizedBox(height: 16),
              Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                studentName,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 4),
              Text('NIM: $studentId', style: TextStyle(color: Colors.white70)),
              SizedBox(height: 12),
              Text(
                'Pendidikan Teknik Informatika',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Ringkasan Akademik',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns = constraints.maxWidth >= 650 ? 3 : 1;
            final double cardWidth =
                (constraints.maxWidth - (columns - 1) * 12) / columns;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Mata Kuliah',
                  value: '${courses.length}',
                  icon: Icons.menu_book_rounded,
                  color: const Color(0xFF4F46E5),
                ),
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Favorit',
                  value: '$favoriteCount',
                  icon: Icons.favorite_rounded,
                  color: const Color(0xFFE11D48),
                ),
                DashboardStatCard(
                  width: cardWidth,
                  title: 'Total SKS',
                  value: '$totalCredits',
                  icon: Icons.auto_stories_rounded,
                  color: const Color(0xFF0891B2),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ValueNotifier Counter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Contoh pengelolaan state sederhana.'),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: counter,
                  builder: (context, value, child) {
                    return Row(
                      children: [
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: () {
                            if (value > 0) {
                              counter.value = value - 1;
                            }
                          },
                          icon: const Icon(Icons.remove),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            counter.value = value + 1;
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Mata Kuliah Terbaru',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(1),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          const EmptyCoursesCard()
        else
          ...courses
              .take(3)
              .map(
                (course) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CourseCard(course: course),
                ),
              ),
      ],
    );
  }
}

// HALAMAN DAFTAR MATA KULIAH
class CoursesPage extends StatefulWidget {
  final List<Course> courses;

  const CoursesPage({super.key, required this.courses});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final String query = searchQuery.toLowerCase();

    final List<Course> filteredCourses = widget.courses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Daftar Mata Kuliah',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('${widget.courses.length} mata kuliah tersedia'),
        const SizedBox(height: 18),
        TextField(
          onChanged: (value) {
            setState(() => searchQuery = value);
          },
          decoration: InputDecoration(
            hintText: 'Cari mata kuliah...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Color(0xFFE11D48)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('${state.favoriteCount} mata kuliah favorit'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (filteredCourses.isEmpty)
          const EmptyCoursesCard()
        else
          ...filteredCourses.map(
            (course) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CourseCard(course: course),
            ),
          ),
      ],
    );
  }
}

// KARTU MATA KULIAH
class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final Course course = widget.course;

    final bool isFavorite = context.select<CourseState, bool>(
      (state) => state.isFavorite(course.id),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.code,
                        style: const TextStyle(
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${course.credits} SKS Ã¢â‚¬Â¢ ${course.category}'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari favorit'
                      : 'Tambahkan ke favorit',
                  onPressed: () {
                    context.read<CourseState>().toggleFavorite(course.id);
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFE11D48) : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      course.status,
                      style: const TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() => expanded = !expanded);
                  },
                  icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(expanded ? 'Tutup' : 'Detail'),
                ),
              ],
            ),
            if (expanded) ...[
              const Divider(height: 24),
              Text(
                course.description.isEmpty
                    ? 'Belum ada deskripsi mata kuliah.'
                    : course.description,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// HALAMAN PROFIL
class ProfilePage extends StatelessWidget {
  final List<Course> courses;

  const ProfilePage({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Profil Mahasiswa',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.person_rounded,
                    size: 46,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  studentName,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('NIM: $studentId'),
                const SizedBox(height: 6),
                const Text(
                  'Pendidikan Teknik Informatika',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Program Studi'),
                  subtitle: const Text('Pendidikan Teknik Informatika'),
                ),
                ListTile(
                  leading: const Icon(Icons.menu_book_outlined),
                  title: const Text('Jumlah Mata Kuliah'),
                  subtitle: Text('${courses.length} mata kuliah'),
                ),
                Consumer<CourseState>(
                  builder: (context, state, child) {
                    return ListTile(
                      leading: const Icon(
                        Icons.favorite,
                        color: Color(0xFFE11D48),
                      ),
                      title: const Text('Mata Kuliah Favorit'),
                      subtitle: Text('${state.favoriteCount} mata kuliah'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// KARTU STATISTIK
class DashboardStatCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DashboardStatCard({
    super.key,
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TAMPILAN KOSONG
class EmptyCoursesCard extends StatelessWidget {
  const EmptyCoursesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Data mata kuliah tidak ditemukan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
