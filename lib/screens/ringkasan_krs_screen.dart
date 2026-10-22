import 'package:flutter/material.dart';

import '../models/matkul.dart';

/// Halaman 3: Ringkasan KRS.
/// Menampilkan state bersama dari widget induk, tanpa menyimpan state sendiri.
class RingkasanKrsScreen extends StatelessWidget {
  final List<Matkul> dipilih;
  final int totalSks;
  final int maxSks;
  final bool terkirim;
  final void Function(Matkul) onHapus;
  final VoidCallback onKirim;

  const RingkasanKrsScreen({
    super.key,
    required this.dipilih,
    required this.totalSks,
    required this.maxSks,
    required this.terkirim,
    required this.onHapus,
    required this.onKirim,
  });

  Future<void> _konfirmasiKirim(BuildContext context) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim KRS?'),
        content: Text(
          'Anda mengambil ${dipilih.length} mata kuliah ($totalSks SKS). '
          'Setelah dikirim, KRS tidak dapat diubah.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Periksa lagi'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Kirim KRS'),
          ),
        ],
      ),
    );
    if (setuju == true) onKirim();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Column(
      children: [
        // Status KRS
        Container(
          width: double.infinity,
          color: terkirim
              ? tema.colorScheme.primaryContainer
              : tema.colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(terkirim ? Icons.check_circle : Icons.edit_note),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  terkirim
                      ? 'Status: Terkirim. Menunggu persetujuan dosen wali.'
                      : 'Status: Draft. Anda masih bisa mengubah KRS.',
                  style: tema.textTheme.titleSmall,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: dipilih.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'KRS masih kosong.\nPilih mata kuliah di tab Mata Kuliah.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: dipilih.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = dipilih[i];
                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        title: Text(m.nama),
                        subtitle: Text('${m.kode}  •  ${m.sks} SKS'),
                        trailing: terkirim
                            ? null
                            : IconButton(
                                tooltip: 'Hapus ${m.nama}',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => onHapus(m),
                              ),
                      ),
                    );
                  },
                ),
        ),
        // Total dan tombol kirim
        Material(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total SKS', style: tema.textTheme.titleMedium),
                    Text(
                      '$totalSks / $maxSks',
                      style: tema.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (terkirim || dipilih.isEmpty)
                        ? null
                        : () => _konfirmasiKirim(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(terkirim ? 'KRS sudah dikirim' : 'Kirim KRS'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
