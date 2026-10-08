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
      title: 'Praktikum Flutter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardTab(),
    CourseListTab(),
    FeedbackFormTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Praktikum Flutter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
        ],
      ),
    );
  }
}

// TAB 1: Dashboard Responsif (LayoutBuilder & Breakpoint)
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isExpanded = constraints.maxWidth >= 600;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.indigo.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          child: Icon(Icons.person, size: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                studentName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('NIM: $studentId'),
                              const Text('Prodi: Pendidikan Teknik Informatika'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Statistik & Tampilan (Width: ${constraints.maxWidth.toStringAsFixed(0)} px)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                if (isExpanded)
                  Row(
                    children: const [
                      Expanded(child: StatCard(title: 'Total Course', value: '6', color: Colors.blue)),
                      SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Selesai', value: '2', color: Colors.green)),
                      SizedBox(width: 12),
                      Expanded(child: StatCard(title: 'Aktif', value: '4', color: Colors.orange)),
                    ],
                  )
                else
                  Column(
                    children: const [
                      StatCard(title: 'Total Course', value: '6', color: Colors.blue),
                      SizedBox(height: 8),
                      StatCard(title: 'Selesai', value: '2', color: Colors.green),
                      SizedBox(height: 8),
                      StatCard(title: 'Aktif', value: '4', color: Colors.orange),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

// TAB 2: Daftar Course & Passing Data
class CourseListTab extends StatelessWidget {
  const CourseListTab({super.key});

  final List<Map<String, dynamic>> courses = const [
    {
      'code': 'MOB01',
      'title': 'Git & GitHub',
      'category': 'Version Control',
      'credits': 2,
      'status': 'Selesai',
      'description': 'Mempelajari perintah dasar Git, branching, commit, serta pengelolaan repositori di GitHub.'
    },
    {
      'code': 'MOB02',
      'title': 'Dart Fundamentals',
      'category': 'Programming',
      'credits': 2,
      'status': 'Selesai',
      'description': 'Konsep dasar bahasa pemrograman Dart, tipe data, fungsi, control flow, dan OOP.'
    },
    {
      'code': 'MOB03',
      'title': 'Flutter UI Fundamentals',
      'category': 'Flutter',
      'credits': 3,
      'status': 'Sedang Dipelajari',
      'description': 'Membangun antarmuka dasar Flutter menggunakan Stateless dan Stateful Widget.'
    },
    {
      'code': 'MOB04',
      'title': 'Responsive Layout',
      'category': 'Flutter',
      'credits': 3,
      'status': 'Aktif',
      'description': 'Menggunakan MediaQuery, LayoutBuilder, dan Flex widget untuk UI yang adaptif.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(child: Text(course['code'].substring(3))),
              title: Text(course['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${course['category']} • ${course['credits']} SKS'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FinalCourseDetailPage(course: course),
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

class FinalCourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  const FinalCourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${course['code']} - ${course['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Kategori: ${course['category']} | SKS: ${course['credits']}'),
            const Divider(height: 24),
            Text(course['description']),
            const Spacer(),
            Text('Praktikan: $studentId - $studentName', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// TAB 3: Form Feedback Interaktif
class FeedbackFormTab extends StatefulWidget {
  const FeedbackFormTab({super.key});

  @override
  State<FeedbackFormTab> createState() => _FeedbackFormTabState();
}

class _FeedbackFormTabState extends State<FeedbackFormTab> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  double _rating = 4.0;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Terima Kasih!'),
          content: Text('Feedback dari $studentName ($studentId) berhasil dikirim.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _feedbackController.clear();
              },
              child: const Text('OK'),
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
            const Text('Form Input Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Rating: ${_rating.toStringAsFixed(1)} Stars'),
            Slider(
              value: _rating,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              onChanged: (val) => setState(() => _rating = val),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Feedback Anda',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Isi feedback terlebih dahulu' : null,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Kirim Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}