import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/providers/mahasiswa_provider.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MahasiswaProvider>().fetchAllMahasiswa(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswaProvider = context.watch<MahasiswaProvider>();
    final data = _filterMahasiswa(mahasiswaProvider.mahasiswa);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Kelola Status'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Search(
                    controller: _searchController,
                    onSearch: () {
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownMenu<String>(
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    menuStyle: MenuStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    hintText: _selectedStatus ?? 'Semua Status',
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: '', label: 'Semua'),
                      DropdownMenuEntry(value: 'lunas', label: 'Lunas'),
                      DropdownMenuEntry(value: 'belum', label: 'Belum'),
                      DropdownMenuEntry(value: 'cicilan', label: 'Cicilan'),
                    ],
                    onSelected: (String? value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            Preset.smallSpace,
            Expanded(
              child: _buildTable(mahasiswaProvider, data),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>>? _filterMahasiswa(List<Map<String, dynamic>>? mahasiswa) {
    if (mahasiswa == null) return null;
    final query = _searchController.text.toLowerCase().trim();
    return mahasiswa.where((item) {
      final nama = _readValue(item, ['nama', 'Nama', 'nama_mahasiswa']).toLowerCase();
      final nim = _readValue(item, ['nim', 'NIM', 'mahasiswa_nim', 'npm']).toLowerCase();
      final status = _normalizeStatus(_readValue(item, ['status', 'Status', 'status_bayar']));

      if (_selectedStatus != null && _selectedStatus!.isNotEmpty && status != _selectedStatus) {
        return false;
      }
      if (query.isEmpty) return true;
      return nama.contains(query) || nim.contains(query) || status.contains(query);
    }).toList();
  }

  Widget _buildTable(MahasiswaProvider provider, List<Map<String, dynamic>>? data) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (data == null || data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tidak ada data mahasiswa.'),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => provider.fetchAllMahasiswa(),
              child: const Text('Muat ulang'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('NIM')),
          DataColumn(label: Text('Nama')),
          DataColumn(label: Text('Jurusan')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: data.map((item) {
          final statusLabel = _readValue(item, ['status', 'Status', 'status_bayar']);
          final status = _normalizeStatus(statusLabel);
          return DataRow(cells: [
            DataCell(Text(_readValue(item, ['nim', 'NIM', 'mahasiswa_nim', 'npm']))),
            DataCell(Text(_readValue(item, ['nama', 'Nama', 'nama_mahasiswa']))),
            DataCell(Text(_readValue(item, ['jurusan', 'Jurusan', 'prodi']))),
            DataCell(_buildStatusChip(status)),
            DataCell(ElevatedButton(
              onPressed: () {},
              child: const Text('Detail', style: TextStyle(fontSize: 12)),
            )),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = switch (status) {
      'lunas' => Preset.saveColor,
      'cicilan' => Preset.editColor,
      _ => Preset.errorColor,
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty ? 'Tidak diketahui' : status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _readValue(Map<String, dynamic> item, List<String> keys) {
    for (final key in keys) {
      final value = item[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  String _normalizeStatus(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('lunas') || lower.contains('paid')) return 'lunas';
    if (lower.contains('cicilan') || lower.contains('installment') || lower.contains('install')) return 'cicilan';
    if (lower.contains('belum')) return 'belum';
    return lower;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
