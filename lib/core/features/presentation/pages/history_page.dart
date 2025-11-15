import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Screening")),
      body: history.isEmpty
          ? const Center(child: Text("Belum ada riwayat."))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final item = history[i];

                final result = item['result']?.toString() ?? 'Unknown';
                final score = item['score']?.toString() ?? '-';
                final tsString = item['timestamp']?.toString();

                DateTime? ts;
                if (tsString != null) {
                  ts = DateTime.tryParse(tsString);
                }

                final formattedDate = ts != null
                    ? '${ts.day}/${ts.month}/${ts.year} '
                          '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}'
                    : (tsString ?? '-');

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12.0,
                  ),
                  title: Text(
                    result,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Skor: $score\nTanggal: $formattedDate"),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Hapus riwayat'),
                          content: const Text('Hapus entry ini dari riwayat?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(historyProvider.notifier).removeAt(i);
                      }
                    },
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Detail Riwayat'),
                        content: Text(
                          'Hasil: $result\n'
                          'Skor: $score\n'
                          'Tanggal: $formattedDate\n\n'
                          'Rekomendasi:\n${item['recommendation'] ?? '-'}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tutup'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete_forever),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Hapus semua riwayat'),
              content: const Text('Anda yakin ingin menghapus semua riwayat?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Hapus Semua'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            await ref.read(historyProvider.notifier).clear();
          }
        },
      ),
    );
  }
}
