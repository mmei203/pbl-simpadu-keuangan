import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/providers/status_provider.dart';
import 'package:mobile/screens/page-edit/ubah_status_page.dart';
import 'package:mobile/utils/config.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  void initState() {
    super.initState();
    // Memanggil fetch data pertama kali saat halaman dibuka lewat Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatusProvider>(
        context,
        listen: false,
      ).fetchStatusMahasiswa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(child: Search()),
                const SizedBox(width: 10),

                // Dropdown Filter Terikat dengan StatusProvider
                Expanded(
                  child: Consumer<StatusProvider>(
                    builder: (context, provider, child) {
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Filter Status',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        value: provider.selectedFilter,
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('Semua')),
                          DropdownMenuItem(
                            value: 'AKTIF',
                            child: Text('Aktif'),
                          ),
                          DropdownMenuItem(
                            value: 'NONAKTIF',
                            child: Text('Nonaktif'),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            provider.setFilter(newValue);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            Preset.smallSpace,

            // --- HEADER TABEL ---
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4FF),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'NIM',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Nama',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Prodi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Aksi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- BODY DATA TABEL MENGGUNAKAN CONSUMER ---
            // 🎯 Pastikan bagian Consumer tabel kamu strukturnya persis seperti ini:
            Expanded(
              child: Consumer<StatusProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 🔥 KUNCI 1: Menggunakan provider.listMahasiswa untuk mendeteksi data kosong
                  if (provider.listMahasiswa.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada data status mahasiswa.\n(Pastikan pencarian atau filter data sesuai)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    // 🔥 KUNCI 2: itemCount harus mengambil dari listMahasiswa yang sudah difilter
                    itemCount: provider.listMahasiswa.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.black12),
                    itemBuilder: (context, index) {
                      // 🔥 KUNCI 3: Objek mhs diambil dari listMahasiswa
                      final mhs = provider.listMahasiswa[index];
                      final bool isAktif = mhs.ukt.toUpperCase() == 'AKTIF';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                mhs.nim.isNotEmpty ? mhs.nim : mhs.id,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                mhs.nama,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                mhs.prodi.contains('|')
                                    ? 'Teknik Informatika'
                                    : mhs.prodi,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Badge Status
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isAktif
                                      ? const Color(0xFF91BAE1)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isAktif ? 'Aktif' : 'Nonaktif',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            // Tombol Aksi Edit
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_note,
                                  color: Color(0xFF1A3D7C),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UbahStatusPage(mahasiswa: mhs),
                                    ),
                                  );
                                  if (result == true) {
                                    provider.fetchStatusMahasiswa();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
