
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_supabase_service.dart';
import 'widgets/error_view.dart';

const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => CourseState(
        CourseRepository(
          CourseSupabaseService(),
        ),
      )..loadCourses(),
      child: const CourseExplorerApp(),
    ),
  );
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
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
            side: const BorderSide(
              color: Color(0xFFE8EAF2),
            ),
          ),
        ),
      ),
      home: const MainResponsiveShell(),
    );
  }
}

// RESPONSIVE SHELL

class MainResponsiveShell extends StatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  State<MainResponsiveShell> createState() =>
      _MainResponsiveShellState();
}

class _MainResponsiveShellState
    extends State<MainResponsiveShell> {
  int selectedIndex = 0;
  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide =
        MediaQuery.sizeOf(context).width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.school_rounded,
              color: Color(0xFF4F46E5),
            ),
            SizedBox(width: 10),
            Text(
              'Course Explorer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
                    child: const Icon(
                      Icons.favorite_rounded,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Consumer<CourseState>(
        builder: (context, state, child) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.error != null) {
            return ErrorView(
              message: state.error!,
              onRetry: state.loadCourses,
            );
          }

          if (state.courses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Data course belum tersedia',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final List<Course> courses = state.courses;

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
                child: IndexedStack(
                  index: selectedIndex,
                  children: pages,
                ),
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
    final int favoriteCount =
        context.watch<CourseState>().favoriteCount;

    final int totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + course.credits,
    );

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4F46E5),
                Color(0xFF7C3AED),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 34,
              ),
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'NIM: $studentId',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
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
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final int columns =
                constraints.maxWidth >= 650 ? 3 : 1;

            final double cardWidth =
                (constraints.maxWidth -
                        (columns - 1) * 12) /
                    columns;

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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Contoh pengelolaan state sederhana.',
                ),
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
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => onNavigate(1),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...courses.take(3).map(
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

  const CoursesPage({
    super.key,
    required this.courses,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String searchQuery = '';
  Future<void> _showCreateCourseDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => const CreateCourseDialog(),
    );

    if (!mounted || created != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mata kuliah berhasil ditambahkan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CourseState>();
    final String query = searchQuery.toLowerCase();

    final List<Course> filteredCourses =
        widget.courses.where((course) {
      return course.title.toLowerCase().contains(query) ||
          course.code.toLowerCase().contains(query) ||
          course.category.toLowerCase().contains(query);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Daftar Mata Kuliah',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
Text('${widget.courses.length} mata kuliah tersedia'),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _showCreateCourseDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Mata Kuliah'),
          ),
        ),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFE11D48),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${state.favoriteCount} mata kuliah favorit',
                  ),
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

  const CourseCard({
    super.key,
    required this.course,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool expanded = false;

  Future<void> _editCourse() async {
    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditCourseDialog(course: widget.course),
    );

    if (!mounted || updated != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mata kuliah berhasil diperbarui.'),
      ),
    );
  }

  Future<void> _deleteCourse() async {
    final course = widget.course;
    final id = course.id;

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ID mata kuliah tidak tersedia.'),
        ),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Mata Kuliah?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus '
          '${course.title} (${course.code})?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    try {
      await context.read<CourseState>().deleteCourse(id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Mata kuliah ${course.code} berhasil dihapus.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus mata kuliah: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Course course = widget.course;

    final bool isFavorite = context.select<CourseState, bool>(
      (state) => state.isFavorite(
        course.id?.toString() ?? course.code,
      ),
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
                      Text(
                        '${course.credits} SKS â€¢ ${course.category}',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari favorit'
                      : 'Tambahkan ke favorit',
                  onPressed: () {
                    context.read<CourseState>().toggleFavorite(
                      course.id?.toString() ?? course.code,
                    );
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFE11D48)
                        : Colors.grey,
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
                  onPressed: _editCourse,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: _deleteCourse,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() => expanded = !expanded);
                  },
                  icon: Icon(
                    expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                  ),
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

// FORM EDIT MATA KULIAH

class EditCourseDialog extends StatefulWidget {
  final Course course;

  const EditCourseDialog({
    super.key,
    required this.course,
  });

  @override
  State<EditCourseDialog> createState() =>
      _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;
  late final TextEditingController _categoryController;
  late final TextEditingController _statusController;
  late final TextEditingController _descriptionController;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    _codeController = TextEditingController(text: course.code);
    _titleController = TextEditingController(text: course.title);
    _creditsController = TextEditingController(
      text: course.credits.toString(),
    );
    _categoryController = TextEditingController(
      text: course.category,
    );
    _statusController = TextEditingController(
      text: course.status,
    );
    _descriptionController = TextEditingController(
      text: course.description,
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    _categoryController.dispose();
    _statusController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    final id = widget.course.id;

    if (id == null) {
      setState(() {
        _errorMessage = 'ID mata kuliah tidak tersedia.';
      });
      return;
    }

    final updatedCourse = Course(
      id: id,
      code: widget.course.code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      category: _categoryController.text.trim(),
      status: _statusController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<CourseState>().updateCourse(
        id,
        updatedCourse,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal menyimpan perubahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Mata Kuliah'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Kode Mata Kuliah',
                    helperText: 'Kode tidak dapat diubah',
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mata Kuliah',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Nama mata kuliah wajib diisi'
                          : null,
                ),
                TextFormField(
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah SKS',
                  ),
                  validator: (value) {
                    final credits =
                        int.tryParse(value?.trim() ?? '');

                    if (credits == null || credits <= 0) {
                      return 'Masukkan jumlah SKS yang valid';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Kategori wajib diisi'
                          : null,
                ),
                TextFormField(
                  controller: _statusController,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Status wajib diisi'
                          : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _save,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}


// FORM TAMBAH MATA KULIAH

class CreateCourseDialog extends StatefulWidget {
  const CreateCourseDialog({super.key});

  @override
  State<CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends State<CreateCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _status = 'planned';
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSubmitting ||
        !_formKey.currentState!.validate()) {
      return;
    }

    final code = _codeController.text.trim();
    final state = context.read<CourseState>();

    final duplicate = state.courses.any(
      (course) => course.code.toLowerCase() == code.toLowerCase(),
    );

    if (duplicate) {
      setState(() {
        _errorMessage = 'Kode mata kuliah sudah digunakan.';
      });
      return;
    }

    final course = Course(
      code: code,
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      category: _categoryController.text.trim(),
      status: _status,
      description: _descriptionController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<CourseState>().createCourse(course);

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Gagal menambahkan mata kuliah: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Mata Kuliah'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Kode Mata Kuliah',
                    hintText: 'Contoh: PTI101',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Kode mata kuliah wajib diisi'
                          : null,
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Mata Kuliah',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Nama mata kuliah wajib diisi'
                          : null,
                ),
                TextFormField(
                  controller: _creditsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah SKS',
                  ),
                  validator: (value) {
                    final credits = int.tryParse(value?.trim() ?? '');

                    if (credits == null || credits <= 0) {
                      return 'Masukkan jumlah SKS yang valid';
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: _categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Kategori wajib diisi'
                          : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'planned',
                      child: Text('Planned'),
                    ),
                    DropdownMenuItem(
                      value: 'active',
                      child: Text('Active'),
                    ),
                    DropdownMenuItem(
                      value: 'done',
                      child: Text('Done'),
                    ),
                  ],
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _save,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}

// HALAMAN PROFIL

class ProfilePage extends StatelessWidget {
  final List<Course> courses;

  const ProfilePage({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Profil Mahasiswa',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
                const ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Program Studi'),
                  subtitle: Text(
                    'Pendidikan Teknik Informatika',
                  ),
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
                      subtitle: Text(
                        '${state.favoriteCount} mata kuliah',
                      ),
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
                    Text(
                      title,
                      style: const TextStyle(color: Colors.grey),
                    ),
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
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: Colors.grey,
            ),
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
