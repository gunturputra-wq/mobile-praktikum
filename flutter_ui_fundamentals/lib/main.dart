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
      home: StageThreePage(),
    );
  }
}

class StageThreePage extends StatelessWidget {
  const StageThreePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tahap 3 - LayoutBuilder & Breakpoint'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Evaluasi Breakpoint berdasarkan constraints.maxWidth
            if (constraints.maxWidth < 600) {
              return CompactLayout(maxWidth: constraints.maxWidth);
            } else if (constraints.maxWidth < 840) {
              return MediumLayout(maxWidth: constraints.maxWidth);
            } else {
              return ExpandedLayout(maxWidth: constraints.maxWidth);
            }
          },
        ),
      ),
    );
  }
}

// 1. Compact Layout (< 600 px)
class CompactLayout extends StatelessWidget {
  final double maxWidth;
  const CompactLayout({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$studentId - $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(
            avatar: const Icon(Icons.phone_android, color: Colors.red),
            label: Text('Compact Layout (${maxWidth.toStringAsFixed(0)} px)'),
            backgroundColor: Colors.red.shade100,
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.view_headline, color: Colors.red),
              title: Text('Tampilan 1 Kolom (Phone)'),
              subtitle: Text('Semua elemen ditumpuk secara vertikal.'),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. Medium Layout (600 - 839 px)
class MediumLayout extends StatelessWidget {
  final double maxWidth;
  const MediumLayout({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$studentId - $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(
            avatar: const Icon(Icons.tablet_android, color: Colors.orange),
            label: Text('Medium Layout (${maxWidth.toStringAsFixed(0)} px)'),
            backgroundColor: Colors.orange.shade100,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.view_module, color: Colors.orange),
                    title: Text('Kolom Kiri'),
                    subtitle: Text('Tablet Portrait / Small Tablet'),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.view_module, color: Colors.orange),
                    title: Text('Kolom Kanan'),
                    subtitle: Text('Tata letak terbagi 2 kolom'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. Expanded Layout (>= 840 px)
class ExpandedLayout extends StatelessWidget {
  final double maxWidth;
  const ExpandedLayout({super.key, required this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.shade50,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$studentId - $studentName', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(
            avatar: const Icon(Icons.desktop_windows, color: Colors.green),
            label: Text('Expanded Layout (${maxWidth.toStringAsFixed(0)} px)'),
            backgroundColor: Colors.green.shade100,
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.grid_view, color: Colors.green),
                    title: Text('Panel 1'),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.grid_view, color: Colors.green),
                    title: Text('Panel 2'),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: ListTile(
                    leading: Icon(Icons.grid_view, color: Colors.green),
                    title: Text('Panel 3'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}