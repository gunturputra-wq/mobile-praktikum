import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'models/course.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'services/course_supabase_service.dart';
import 'services/profile_service.dart';
import 'widgets/error_view.dart';
import 'widgets/role_guard.dart';

const String studentName = 'I Ketut Guntur Putra Dangin';
const String studentId = '2415051056';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Supabase.initialize(
    url: 'https://genbvfarqheeshjikngk.supabase.co',
    publishableKey: 'sb_publishable_S859tk3ygOY25Sz8oMBt6Q_OamfRnOO',
  );

  // Mendengarkan perubahan session (otomatis redirect ke LoginPage jika signedOut)
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    debugPrint('Auth event: ${data.event}');

    if (data.event == AuthChangeEvent.signedOut) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  });

  runApp(const CourseExplorerApp());
}

/// Fungsi pengujian keamanan RLS (Praktik 6)
Future<String> runCourseSecurityTest({
  required int courseIdMilikUserA,
  required String uuidUserA,
}) async {
  final client = Supabase.instance.client;
  final service = CourseSupabaseService();
  final buffer = StringBuffer();

  // 1. User B mencoba mengubah (UPDATE) data User A -> harus DENIED
  try {
    await service.updateCourse(
      courseIdMilikUserA,
      const Course(
        code: 'HACK999',
        title: 'DIUBAH USER B',
        credits: 3,
        category: 'Test',
        status: 'active',
      ),
    );
    buffer.writeln('[FAIL] User B berhasil mengubah data User A');
  } catch (e) {
    buffer.writeln('[PASS] UPDATE ditolak oleh RLS');
  }

  // 2. User B mencoba menghapus (DELETE) data User A -> harus DENIED
  try {
    await service.deleteCourse(courseIdMilikUserA);
    buffer.writeln('[FAIL] User B berhasil menghapus data User A');
  } catch (e) {
    buffer.writeln('[PASS] DELETE ditolak oleh RLS');
  }

  // 3. User B mencoba INSERT atas nama User A -> harus ERROR 42501
  try {
    await client.from('courses').insert({
      'owner_id': uuidUserA,
      'code': 'FAKE101',
      'title': 'Course Palsu',
      'credits': 2,
      'category': 'Security',
      'status': 'planned',
    });
    buffer.writeln('[FAIL] INSERT atas nama user lain berhasil');
  } on PostgrestException catch (e) {
    buffer.writeln('[PASS] INSERT ditolak (${e.code}): ${e.message}');
  } catch (e) {
    buffer.writeln('[PASS] INSERT ditolak: $e');
  }

  final hasil = buffer.toString();
  debugPrint(hasil);
  return hasil;
}

class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'Course Explorer',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
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
      home: isLoggedIn ? const MainResponsiveShellWrapper() : const LoginPage(),
    );
  }
}

class MainResponsiveShellWrapper extends StatelessWidget {
  const MainResponsiveShellWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CourseState(
        CourseRepository(
          CourseSupabaseService(),
        ),
      )..loadCourses(),
      child: const MainResponsiveShell(),
    );
  }
}

// ==========================================
// HALAMAN LOGIN & REGISTER
// ==========================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 40,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailC.text.trim(),
        password: _passC.text,
      );
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainResponsiveShellWrapper()),
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      String pesanError = 'Terjadi kesalahan saat login. Silakan coba lagi.';
      if (e.message.contains('Invalid login credentials')) {
        pesanError = 'Maaf, password atau email yang Anda masukkan salah.';
      } else if (e.message.contains('Email not confirmed')) {
        pesanError = 'Email Anda belum diverifikasi. Silakan periksa kotak masuk email Anda.';
      }

      _showAlert('Login Gagal', pesanError);
    } catch (_) {
      if (!mounted) return;
      _showAlert(
        'Koneksi Bermasalah',
        'Terjadi kesalahan. Periksa koneksi internet Anda.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Course Explorer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school_rounded, size: 64, color: Color(0xFF4F46E5)),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang Kembali!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Login', style: TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                ),
                child: const Text('Belum punya akun? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();
  String _role = 'seeker';
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailC.text.trim(),
        password: _passC.text,
        data: {
          'name': _nameC.text.trim(),
          'role': _role,
        },
      );
      if (!mounted) return;

      if (res.session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainResponsiveShellWrapper()),
          (route) => false,
        );
      } else {
        _showMessage('Registrasi berhasil. Silakan cek email Anda.');
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      String pesanError = e.message;
      if (e.message.contains('User already registered')) {
        pesanError = 'Email ini sudah terdaftar. Silakan langsung login.';
      }
      _showMessage(pesanError);
    } catch (_) {
      _showMessage('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Akun Baru')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: 'Daftar sebagai',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: const [
                  DropdownMenuItem(value: 'seeker', child: Text('Seeker (Mahasiswa / Pencari)')),
                  DropdownMenuItem(value: 'owner', child: Text('Owner (Dosen / Pemilik)')),
                ],
                onChanged: (v) => setState(() => _role = v ?? 'seeker'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                  if (!v.contains('@')) return 'Format email tidak valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmC,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                validator: (v) => v != _passC.text ? 'Password tidak sama' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Register', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// RESPONSIVE SHELL
// ==========================================

class MainResponsiveShell extends StatefulWidget {
  const MainResponsiveShell({super.key});

  @override
  State<MainResponsiveShell> createState() =>
      _MainResponsiveShellState();
}

class _MainResponsiveShellState
    extends State<MainResponsiveShell> {
  String _permissionStatus = 'notDetermined';

  Future<void> _initNotificationPermission() async {
    final status = await NotificationService.instance.requestPermission();
    if (mounted) {
      setState(() {
        _permissionStatus = status.name;
      });
    }
    final token = await NotificationService.instance.getToken();
    if (token != null) {
      try {
        await NotificationService.instance.saveTokenToSupabase(token);
      } catch (e) {
        debugPrint('Supabase saveToken skipped: $e');
      }
    }
    NotificationService.instance.listenTokenRefresh((newToken) async {
      try {
        await NotificationService.instance.saveTokenToSupabase(newToken);
      } catch (e) {
        debugPrint('Supabase saveToken refresh skipped: $e');
      }
    });
  }
  int selectedIndex = 0;
  final ValueNotifier<int> counter = ValueNotifier<int>(0);
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
    _initNotificationPermission();
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide =
        MediaQuery.sizeOf(context).width >= 800;

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, profileSnap) {
        if (profileSnap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final UserProfile? userProfile = profileSnap.data;
        final String currentRole = userProfile?.role ?? 'seeker';

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
            TextButton.icon(
              onPressed: _initNotificationPermission,
              icon: Icon(
                _permissionStatus == 'authorized' ? Icons.notifications_active : Icons.notifications_off,
                color: _permissionStatus == 'authorized' ? Colors.green : Colors.orange,
              ),
              label: Text('Izin: $_permissionStatus'),
            ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(
                  label: Text(
                    currentRole.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  backgroundColor: const Color(0xFFEEF2FF),
                  side: BorderSide.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
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
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                onPressed: _logout,
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
                  userProfile: userProfile,
                  onNavigate: (index) {
                    setState(() => selectedIndex = index);
                  },
                ),
                CoursesPage(
                  courses: courses,
                  userRole: currentRole,
                ),
                ProfilePage(
                  courses: courses,
                  userProfile: userProfile,
                ),
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
      },
    );
  }
}

// ==========================================
// DASHBOARD
// ==========================================

class HomePage extends StatelessWidget {
  final List<Course> courses;
  final ValueNotifier<int> counter;
  final ValueChanged<int> onNavigate;
  final UserProfile? userProfile;

  const HomePage({
    super.key,
    required this.courses,
    required this.counter,
    required this.onNavigate,
    this.userProfile,
  });

  /// Dialog untuk menjalankan Security Test Praktik 6 secara interaktif
  void _openSecurityTestDialog(BuildContext context) {
    final firstCourse = courses.isNotEmpty ? courses.first : null;
    final idController = TextEditingController(
      text: firstCourse?.id?.toString() ?? '',
    );
    final uuidController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Security Test RLS (Praktik 6)'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan ID Course & UUID milik User A saat login sebagai User B untuk menguji penolakan RLS:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: idController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID Course milik User A',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: uuidController,
                decoration: const InputDecoration(
                  labelText: 'UUID User A (dari Supabase Users)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            onPressed: () async {
              final targetId = int.tryParse(idController.text.trim());
              final targetUuid = uuidController.text.trim();
              if (targetId == null || targetUuid.isEmpty) return;

              Navigator.pop(dialogContext);
              final hasil = await runCourseSecurityTest(
                courseIdMilikUserA: targetId,
                uuidUserA: targetUuid,
              );

              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Hasil Security Test RLS'),
                  content: SelectableText(hasil),
                  actions: [
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jalankan Test'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int favoriteCount =
        context.watch<CourseState>().favoriteCount;

    final int totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + course.credits,
    );

    final String displayName = (userProfile?.name.isNotEmpty ?? false)
        ? userProfile!.name
        : studentName;
    final String currentUserEmail = userProfile?.email ??
        Supabase.instance.client.auth.currentUser?.email ??
        '-';
    final String currentUserRole = userProfile?.role ?? 'seeker';
    final String currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '-';

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.waving_hand_rounded,
                color: Colors.white,
                size: 34,
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'NIM: $studentId',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Email: $currentUserEmail',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Role: $currentUserRole',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'UID: $currentUserId',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 12),
              const Text(
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
        // Panel pengujian keamanan RLS untuk Praktik 6
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF4F46E5), size: 32),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Testing RLS',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Uji penolakan UPDATE, DELETE, dan INSERT lintas akun.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _openSecurityTestDialog(context),
                  icon: const Icon(Icons.bug_report_outlined),
                  label: const Text('Uji RLS'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (userProfile?.isAdmin ?? false) ...[
          Card(
            color: const Color(0xFFEEF2FF),
            child: const ListTile(
              leading: Icon(Icons.admin_panel_settings, color: Color(0xFF4F46E5)),
              title: Text(
                'Panel Kelola Data (Admin)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Akses penuh pengelolaan seluruh data mata kuliah & pengguna.'),
            ),
          ),
          const SizedBox(height: 24),
        ],
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
            child: CourseCard(
              course: course,
              userRole: currentUserRole,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// HALAMAN DAFTAR MATA KULIAH
// ==========================================

class CoursesPage extends StatefulWidget {
  final List<Course> courses;
  final String userRole;

  const CoursesPage({
    super.key,
    required this.courses,
    required this.userRole,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String searchQuery = '';

  Future<void> _showCreateCourseDialog() async {
    final courseState = context.read<CourseState>();
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: courseState,
        child: const CreateCourseDialog(),
      ),
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
        // Tombol Tambah Mata Kuliah hanya muncul untuk role 'owner' dan 'admin'
        RoleGuard(
          role: widget.userRole,
          allowed: const ['owner', 'admin'],
          child: Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _showCreateCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mata Kuliah'),
            ),
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
              child: CourseCard(
                course: course,
                userRole: widget.userRole,
              ),
            ),
          ),
      ],
    );
  }
}

// ==========================================
// KARTU MATA KULIAH
// ==========================================

class CourseCard extends StatefulWidget {
  final Course course;
  final String userRole;

  const CourseCard({
    super.key,
    required this.course,
    required this.userRole,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool expanded = false;

  Future<void> _editCourse() async {
    final courseState = context.read<CourseState>();
    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: courseState,
        child: EditCourseDialog(course: widget.course),
      ),
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
        course.code,
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
                        '${course.code} (ID: ${course.id ?? '-'})',
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
                        '${course.credits} SKS • ${course.category}',
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
                      course.code,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Container(
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RoleGuard(
                      role: widget.userRole,
                      allowed: const ['owner', 'admin'],
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            onPressed: _editCourse,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Edit'),
                          ),
                          TextButton.icon(
                            onPressed: _deleteCourse,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: const Text('Delete'),
                          ),
                        ],
                      ),
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

// ==========================================
// FORM EDIT MATA KULIAH
// ==========================================

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

// ==========================================
// FORM TAMBAH MATA KULIAH
// ==========================================

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

// ==========================================
// HALAMAN PROFIL
// ==========================================

class ProfilePage extends StatelessWidget {
  final List<Course> courses;
  final UserProfile? userProfile;

  const ProfilePage({
    super.key,
    required this.courses,
    this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = (userProfile?.name.isNotEmpty ?? false)
        ? userProfile!.name
        : studentName;
    final String currentUserEmail = userProfile?.email ??
        Supabase.instance.client.auth.currentUser?.email ??
        '-';
    final String currentUserRole = userProfile?.role ?? '-';
    final String currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '-';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Profil Pengguna',
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
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
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
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Nama'),
                  subtitle: Text(displayName),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(currentUserEmail),
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: Color(0xFF4F46E5)),
                  title: const Text('Role'),
                  subtitle: Text(
                    currentUserRole,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('User ID (UUID)'),
                  subtitle: SelectableText(currentUserId),
                ),
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

// ==========================================
// KARTU STATISTIK
// ==========================================

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

// ==========================================
// TAMPILAN KOSONG
// ==========================================

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

