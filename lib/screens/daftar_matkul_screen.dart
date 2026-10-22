import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/matkul.dart';

/// State lokal: _kataPencarian, _semesterDipilih.
/// Data KRS (dipilih, totalSks, terkirim) diterima dari widget induk.
class DaftarMatkulScreen extends StatefulWidget {
  final List<Matkul> dipilih;
  final int totalSks;
  final int maxSks;
  final bool terkirim;
  final void Function(Matkul) onAmbil;
  final void Function(Matkul) onHapus;

  const DaftarMatkulScreen({
    super.key,
    required this.dipilih,
    required this.totalSks,
    required this.maxSks,
    required this.terkirim,
    required this.onAmbil,
    required this.onHapus,
  });

  @override
  State<DaftarMatkulScreen> createState() => _DaftarMatkulScreenState();
}

class _DaftarMatkulScreenState extends State<DaftarMatkulScreen> {
  String _kataPencarian = '';
  int _semesterDipilih = 0; // 0 = semua semester

  List<Matkul> get _hasil {
    final kata = _kataPencarian.toLowerCase();
    return semuaMatkul.where((m) {
      final cocokSemester =
          _semesterDipilih == 0 || m.semester == _semesterDipilih;
      final cocokKata = m.nama.toLowerCase().contains(kata) ||
          m.kode.toLowerCase().contains(kata);
      return cocokSemester && cocokKata;
    }).toList();
  }

  bool _sudahDiambil(Matkul m) => widget.dipilih.any((x) => x.kode == m.kode);

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final penuh = widget.totalSks >= widget.maxSks;
    final hasil = _hasil;

    return Column(
      children: [
        // Indikator SKS
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total SKS', style: tema.textTheme.labelLarge),
                  Text(
                    '${widget.totalSks} / ${widget.maxSks}',
                    style: tema.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: penuh ? tema.colorScheme.error : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: widget.totalSks / widget.maxSks,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
                color: penuh ? tema.colorScheme.error : null,
              ),
              if (penuh)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Batas SKS tercapai. Hapus mata kuliah untuk mengambil yang lain.',
                    style: tema.textTheme.bodySmall
                        ?.copyWith(color: tema.colorScheme.error),
                  ),
                ),
              if (widget.terkirim)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'KRS sudah dikirim dan tidak dapat diubah.',
                    style: tema.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
        // Pencarian dan filter
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari nama atau kode',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _kataPencarian = v),
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _semesterDipilih,
                items: [
                  const DropdownMenuItem(value: 0, child: Text('Semua')),
                  for (var s = 1; s <= 5; s++)
                    DropdownMenuItem(value: s, child: Text('Sem $s')),
                ],
                onChanged: (v) => setState(() => _semesterDipilih = v ?? 0),
              ),
            ],
          ),
        ),
        // Daftar
        Expanded(
          child: hasil.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada mata kuliah yang cocok.\nCoba kata kunci lain.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: hasil.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = hasil[i];
                    final diambil = _sudahDiambil(m);
                    final melebihi = widget.totalSks + m.sks > widget.maxSks;
                    return Card(
                      margin: EdgeInsets.zero,
                      color: diambil ? tema.colorScheme.primaryContainer : null,
                      child: ListTile(
                        title: Text(m.nama),
                        subtitle: Text(
                            '${m.kode}  •  ${m.sks} SKS  •  Semester ${m.semester}'),
                        trailing: _tombol(m, diambil, melebihi),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _tombol(Matkul m, bool diambil, bool melebihi) {
    if (diambil) {
      return OutlinedButton(
        onPressed: widget.terkirim ? null : () => widget.onHapus(m),
        child: const Text('Batal'),
      );
    }
    return FilledButton(
      onPressed: (widget.terkirim || melebihi) ? null : () => widget.onAmbil(m),
      child: Text(melebihi && !widget.terkirim ? 'SKS penuh' : 'Ambil'),
    );
  }
}
