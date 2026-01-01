// lib/pages/peminjaman/peminjaman_laporan.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/peminjaman_service.dart';

class LaporanPeminjamanPage extends StatefulWidget {
  const LaporanPeminjamanPage({super.key});

  @override
  State<LaporanPeminjamanPage> createState() => _LaporanPeminjamanPageState();
}

class _LaporanPeminjamanPageState extends State<LaporanPeminjamanPage> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _status; // "dipinjam" | "kembali" | null

  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    // awal: semua peminjaman
    _future = PeminjamanService.fetchPeminjaman();
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return DateFormat('dd/MM/yyyy').format(d);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart = _startDate ?? DateTime(now.year, now.month, 1);
    final initialEnd = _endDate ?? now;

    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (result != null) {
      setState(() {
        _startDate = result.start;
        _endDate = result.end;
      });
      _reload();
    }
  }

  void _reload() {
    setState(() {
      _future = PeminjamanService.fetchPeminjaman(
        status: _status,
        start: _startDate,
        end: _endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Peminjaman')),
      body: Column(
        children: [
          // FILTER
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    _startDate == null || _endDate == null
                        ? 'Semua tanggal'
                        : '${_formatDate(_startDate)} - ${_formatDate(_endDate)}',
                  ),
                ),
                DropdownButton<String>(
                  value: _status,
                  hint: const Text('Semua status'),
                  items: const [
                    DropdownMenuItem(
                      value: 'dipinjam',
                      child: Text('Masih dipinjam'),
                    ),
                    DropdownMenuItem(
                      value: 'kembali',
                      child: Text('Sudah kembali'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _status = value);
                    _reload();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 0),

          // TABEL
          Expanded(
            child: FutureBuilder<List>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat laporan: ${snapshot.error}'),
                  );
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('Tidak ada data peminjaman'));
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('No')),
                      DataColumn(label: Text('Tgl Pinjam')),
                      DataColumn(label: Text('Anggota')),
                      DataColumn(label: Text('Buku')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: List<DataRow>.generate(data.length, (index) {
                      final p = data[index] as Map;
                      final anggota = (p['anggota'] ?? {}) as Map;
                      final buku = (p['buku'] ?? {}) as Map;

                      final tglPinjamRaw = p['tanggal_pinjam'];
                      DateTime? tglPinjam;
                      if (tglPinjamRaw != null) {
                        tglPinjam = DateTime.tryParse(tglPinjamRaw.toString());
                      }

                      final status = (p['status'] ?? '').toString();

                      return DataRow(
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(_formatDate(tglPinjam))),
                          DataCell(
                            Text(
                              (anggota['nama_anggota'] ?? p['nama'] ?? '-')
                                  .toString(),
                            ),
                          ),
                          DataCell(
                            Text(
                              (buku['judul'] ?? p['judul'] ?? '-').toString(),
                            ),
                          ),
                          DataCell(Text(status)),
                        ],
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
