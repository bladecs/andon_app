import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Stream<List<Map<String, dynamic>>> getAndonData() {
    final AudioPlayer _audioPlayer = AudioPlayer();
    List<String> _lastKeys = [];
    final databaseref = FirebaseDatabase.instance.ref();
    final ref = databaseref.child('andonEvents');

    return ref.onValue.map((event) {
      final Map<dynamic, dynamic>? data = event.snapshot.value as Map?;
      final List<Map<String, dynamic>> items = [];

      if (data != null) {
        data.forEach((key, value) {
          items.add({
            'issue': value['issue']?.toString() ?? '-',
            'machine_id': value['machine_id']?.toString() ?? '-',
            'status': value['status']?.toString() ?? '-',
            'timestamp': value['timestamp']?.toString() ?? '-',
          });
        });

        // Deteksi data baru
        final currentKeys = data.keys.map((e) => e.toString()).toList();
        if (_lastKeys.isNotEmpty && currentKeys.length > _lastKeys.length) {
          // Ada data baru, play musik
          _audioPlayer.play(AssetSource('audio/sound-alert.mp3'));
        }
        _lastKeys = currentKeys;
      }

      return items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Andon App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getAndonData(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Error state
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Data kosong
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data'));
                }

                final data = snapshot.data!;
                // Urutkan data terbaru di atas (asumsi timestamp bisa di-parse ke int)
                data.sort((a, b) =>
                    (a['timestamp'] ?? '').compareTo(b['timestamp'] ?? ''));

                // Pagination
                const int rowsPerPage = 10;
                int pageCount = (data.length / rowsPerPage).ceil();
                ValueNotifier<int> pageNotifier = ValueNotifier<int>(0);

                return ValueListenableBuilder<int>(
                  valueListenable: pageNotifier,
                  builder: (context, pageIndex, _) {
                    final start = pageIndex * rowsPerPage;
                    final end = (start + rowsPerPage) > data.length
                        ? data.length
                        : (start + rowsPerPage);
                    final pageData = data.sublist(start, end);

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Issue')),
                                DataColumn(label: Text('Machine ID')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Timestamp')),
                              ],
                              rows: pageData.map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(item['issue'])),
                                    DataCell(Text(item['machine_id'])),
                                    DataCell(
                                      Text(
                                        item['status'],
                                        style: TextStyle(
                                          color: item['status'] == 'Active'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(item['timestamp'])),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: pageIndex > 0
                                  ? () => pageNotifier.value = pageIndex - 1
                                  : null,
                            ),
                            Text('Halaman ${pageIndex + 1} dari $pageCount'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: pageIndex < pageCount - 1
                                  ? () => pageNotifier.value = pageIndex + 1
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}