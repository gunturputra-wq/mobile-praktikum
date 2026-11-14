import '../services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';
import '../models/course.dart';
import '../services/course_supabase_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';

class ScreenHomePage extends StatefulWidget {
  const ScreenHomePage({super.key});

  @override
  State<ScreenHomePage> createState() => _ScreenHomePageState();
}

class _ScreenHomePageState extends State<ScreenHomePage> {
  String _permissionStatus = 'notDetermined';

  Future<void> _initNotificationPermission() async {
    final status = await NotificationService.instance.requestPermission();
    if (mounted) {
      setState(() {
        _permissionStatus = status.name;
      });
    }
  }
  late final Future<UserProfile?> _profileFuture;
  late Future<List<Course>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
    _initNotificationPermission();
    _coursesFuture = CourseSupabaseService().getCourses();
  }

  void _refreshCourses() {
    setState(() {
      _coursesFuture = CourseSupabaseService().getCourses();
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _showAddCourseDialog() {
    final codeC = TextEditingController();
    final titleC = TextEditingController();
    final creditsC = TextEditingController();
    final categoryC = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Mata Kuliah'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeC,
                decoration: const InputDecoration(labelText: 'Kode (contoh: PTI101)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: creditsC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah SKS'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryC,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
            ],
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (codeC.text.trim().isEmpty || titleC.text.trim().isEmpty) return;
              try {
                await CourseSupabaseService().createCourse(
                  Course(
                    code: codeC.text.trim(),
                    title: titleC.text.trim(),
                    credits: int.tryParse(creditsC.text.trim()) ?? 3,
                    category: categoryC.text.trim(),
                    status: 'planned',
                  ),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _refreshCourses();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mata kuliah berhasil ditambahkan')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menambah mata kuliah: $e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Course course) {
    final titleC = TextEditingController(text: course.title);
    final creditsC = TextEditingController(text: '${course.credits}');
    final categoryC = TextEditingController(text: course.category);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit ${course.code}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleC,
                decoration: const InputDecoration(labelText: 'Nama Mata Kuliah'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: creditsC,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah SKS'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: categoryC,
                decoration: const InputDecoration(labelText: 'Kategori'),
              ),
            ],
          ),
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
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (course.id == null) return;
              try {
                await CourseSupabaseService().updateCourse(
                  course.id!,
                  Course(
                    id: course.id,
                    code: course.code,
                    title: titleC.text.trim(),
                    credits: int.tryParse(creditsC.text.trim()) ?? course.credits,
                    category: categoryC.text.trim(),
                    status: course.status,
                    description: course.description,
                  ),
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                _refreshCourses();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mata kuliah berhasil diperbarui')),
                );
              } catch (e) {
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myId = Supabase.instance.client.auth.currentUser?.id;

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final p = snap.data;
        if (snap.hasError || p == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Course Explorer'),
              actions: [
            TextButton.icon(
              onPressed: _initNotificationPermission,
              icon: Icon(
                _permissionStatus == 'authorized' ? Icons.notifications_active : Icons.notifications_off,
                color: _permissionStatus == 'authorized' ? Colors.green : Colors.orange,
              ),
              label: Text('Izin: $_permissionStatus'),
            ),
                IconButton(
                  tooltip: 'Logout',
                  icon: const Icon(Icons.logout),
                  onPressed: _logout,
                ),
              ],
            ),
            body: const Center(child: Text('Gagal memuat profil')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Course Explorer (${p.role})'),
            actions: [
            TextButton.icon(
              onPressed: _initNotificationPermission,
              icon: Icon(
                _permissionStatus == 'authorized' ? Icons.notifications_active : Icons.notifications_off,
                color: _permissionStatus == 'authorized' ? Colors.green : Colors.orange,
              ),
              label: Text('Izin: $_permissionStatus'),
            ),
              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(p.name.isEmpty ? p.email : p.name),
                subtitle: Text('${p.email} • ${p.role}\nUID: ${p.id}'),
                isThreeLine: true,
              ),
              const Divider(),
              FutureBuilder<List<Course>>(
                future: _coursesFuture,
                builder: (context, courseSnap) {
                  if (courseSnap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (courseSnap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Gagal memuat mata kuliah: ${courseSnap.error}'),
                    );
                  }

                  final items = courseSnap.data ?? [];
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('Belum ada data mata kuliah.')),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final course = items[i];
                      final isMine = course.ownerId == myId || p.isAdmin;

                      return ListTile(
                        title: Text('${course.code} - ${course.title}'),
                        subtitle: Text(
                          '${course.credits} SKS • ${course.category}\nID: ${course.id ?? '-'}',
                        ),
                        isThreeLine: true,
                        trailing: isMine
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEditCourseDialog(course),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      if (course.id == null) return;
                                      try {
                                        await CourseSupabaseService().deleteCourse(course.id!);
                                        if (!mounted) return;
                                        _refreshCourses();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Mata kuliah berhasil dihapus'),
                                          ),
                                        );
                                      } catch (e) {
                                        if (!mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('$e')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              )
                            : null,
                      );
                    },
                  );
                },
              ),
            ],
          ),
          floatingActionButton: RoleGuard(
            role: p.role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: _showAddCourseDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mata Kuliah'),
            ),
          ),
        );
      },
    );
  }
}