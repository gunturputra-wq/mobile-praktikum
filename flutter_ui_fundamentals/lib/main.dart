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
      home: Scaffold(
        appBar: AppBar(title: const Text('Tahap 1 - Local State')),
        body: const LocalStateExample(),
      ),
    );
  }
}

class LocalStateExample extends StatefulWidget {
  const LocalStateExample({super.key});

  @override
  State<LocalStateExample> createState() => _LocalStateExampleState();
}

class _LocalStateExampleState extends State<LocalStateExample> {
  // Local State: Hanya digunakan di dalam widget ini saja
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$studentId - $studentName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              title: const Text('Matakulating: Pemrograman Mobile'),
              subtitle: const Text('Contoh penggunaan local state setState()'),
              trailing: IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  // Mengubah Local State
                  setState(() {
                    isFavorite = !isFavorite;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}