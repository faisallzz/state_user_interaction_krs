import 'package:flutter/material.dart';

import '../models/matkul.dart';
import 'daftar_matkul_screen.dart';
import 'login_screen.dart';
import 'ringkasan_krs_screen.dart';

/// Kerangka utama setelah login.
///
/// STATE UTAMA ada di sini (di-"angkat" ke widget induk) supaya dipakai
/// bersama oleh halaman Daftar Mata Kuliah dan halaman Ringkasan KRS:
///   - _dipilih   : daftar mata kuliah yang diambil
///   - _terkirim  : status KRS (draft / terkirim)
///   - _tabAktif  : tab yang sedang dibuka
/// _totalSks adalah state turunan: dihitung dari _dipilih.
class KrsHome extends StatefulWidget {
  final String nim;
  final String nama;

  const KrsHome({super.key, required this.nim, required this.nama});

  @override
  State<KrsHome> createState() => _KrsHomeState();
}

class _KrsHomeState extends State<KrsHome> {
  static const int maxSks = 24;

  final List<Matkul> _dipilih = [];
  bool _terkirim = false;
  int _tabAktif = 0;

  int get _totalSks => _dipilih.fold(0, (jumlah, m) => jumlah + m.sks);

  void _pesan(String teks) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks)));
  }

  void _ambil(Matkul m) {
    if (_terkirim) return;
    if (_totalSks + m.sks > maxSks) {
      _pesan('Batas $maxSks SKS terlampaui. ${m.nama} tidak dapat diambil.');
      return;
    }
    setState(() => _dipilih.add(m));
    _pesan('${m.nama} ditambahkan ke KRS.');
  }

  void _hapus(Matkul m) {
    if (_terkirim) return;
    setState(() => _dipilih.removeWhere((x) => x.kode == m.kode));
    _pesan('${m.nama} dihapus dari KRS.');
  }

  void _kirim() {
    setState(() => _terkirim = true);
    _pesan('KRS berhasil dikirim. Menunggu persetujuan dosen wali.');
  }

  void _keluar() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.nama, style: const TextStyle(fontSize: 16)),
            Text(
              'NIM ${widget.nim}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: _keluar,
          ),
        ],
      ),
      // IndexedStack menjaga state lokal tiap tab (mis. kata pencarian)
      body: IndexedStack(
        index: _tabAktif,
        children: [
          DaftarMatkulScreen(
            dipilih: _dipilih,
            totalSks: _totalSks,
            maxSks: maxSks,
            terkirim: _terkirim,
            onAmbil: _ambil,
            onHapus: _hapus,
          ),
          RingkasanKrsScreen(
            dipilih: _dipilih,
            totalSks: _totalSks,
            maxSks: maxSks,
            terkirim: _terkirim,
            onHapus: _hapus,
            onKirim: _kirim,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabAktif,
        onDestinationSelected: (i) => setState(() => _tabAktif = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Mata Kuliah',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _dipilih.isNotEmpty,
              label: Text('${_dipilih.length}'),
              child: const Icon(Icons.fact_check_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _dipilih.isNotEmpty,
              label: Text('${_dipilih.length}'),
              child: const Icon(Icons.fact_check),
            ),
            label: 'Ringkasan KRS',
          ),
        ],
      ),
    );
  }
}
