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
      title: 'Tahap 16 - Debugging Challenge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DebuggingPage(),
    );
  }
}

class DebuggingPage extends StatefulWidget {
  const DebuggingPage({super.key});

  @override
  State<DebuggingPage> createState() => _DebuggingPageState();
}

class _DebuggingPageState extends State<DebuggingPage> {
  final _textController = TextEditingController();
  bool _isNavigating = false; // Mencegah double push (Kasus D)

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // Mencegah Navigasi Ganda (Kasus D)
  void _safeNavigate() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigasi diproses (Aksi Ganda Dicegah)')),
    );

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 16: Debugging'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      // KASUS C: Menggunakan SingleChildScrollView agar tidak overflow saat keyboard muncul
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Mahasiswa
            Card(
              color: Colors.indigo.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      '$studentId - $studentName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // KASUS A: Menggunakan Expanded di dalam Row agar teks panjang tidak overflow
            const Text('Kasus A: Teks Panjang dalam Row', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade200,
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  // SOLUSI KASUS A: Expanded
                  Expanded(
                    child: Text(
                      '$studentId - $studentName - Teks ini sangat panjang sekali agar membuktikan bahwa tidak terjadi RenderFlex overflow!',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // KASUS B: ListView di dalam Column dibatasi tingginya (SizedBox/Expanded)
            const Text('Kasus B: ListView dalam Column', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // SOLUSI KASUS B: Memberi batasan tinggi pada ListView
            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      dense: true,
                      title: Text('Item $index - Tampil Tanpa Error Unbounded Height'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // KASUS C: Form di bagian bawah (Keyboard Safe)
            const Text('Kasus C: Keyboard Safe Form', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Ketik di sini untuk tes keyboard',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // KASUS D: Mencegah Double Click/Navigasi Ganda
            const Text('Kasus D: Prevent Double Click', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isNavigating ? null : _safeNavigate,
                icon: const Icon(Icons.touch_app),
                label: Text(_isNavigating ? 'Memproses...' : 'Tekan Cepat (Anti Double Click)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}