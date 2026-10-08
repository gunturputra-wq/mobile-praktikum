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
    return const MaterialApp(
      home: FeedbackFormPage(),
    );
  }
}

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: studentName);
  final _feedbackController = TextEditingController();
  double _rating = 3.0;

  @override
  void dispose() {
    _nameController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String name, String feedback, double rating) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feedback Terkirim!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: $name'),
            const SizedBox(height: 4),
            Text('Rating: ${rating.toStringAsFixed(1)} / 5.0'),
            const SizedBox(height: 8),
            Text('Pesan: $feedback'),
          ],
        ),
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

  void _showConfirmationBottomSheet() {
    if (_formKey.currentState!.validate()) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Konfirmasi Pengiriman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text('Mahasiswa: $studentId - $studentName'),
                const SizedBox(height: 8),
                Text('Rating: ${_rating.toStringAsFixed(1)} Stars'),
                const SizedBox(height: 8),
                Text('Feedback: ${_feedbackController.text}'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup BottomSheet
                        _showSuccessDialog(
                          _nameController.text,
                          _feedbackController.text,
                          _rating,
                        );
                      },
                      child: const Text('Kirim Sekarang'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 9 - User Interaction & Form'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identitas Mahasiswa
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '$studentId - $studentName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Form Nama
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Slider Rating
                Text(
                  'Penilaian Materi: ${_rating.toStringAsFixed(1)} / 5.0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Slider(
                  value: _rating,
                  min: 1.0,
                  max: 5.0,
                  divisions: 8,
                  label: _rating.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      _rating = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Input Feedback
                TextFormField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Masukkan Feedback / Komentar',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Feedback tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _showConfirmationBottomSheet,
                    icon: const Icon(Icons.send),
                    label: const Text('Kirim Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}