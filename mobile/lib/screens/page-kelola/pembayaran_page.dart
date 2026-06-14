import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/providers/pembayaran_provider.dart';
import 'package:mobile/screens/page-edit/ubah_pembayaran_page.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PembayaranProvider>(context, listen: false).fetchTagihan();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return const Color(0xFFC2F0C2);
      case 'belum':
        return const Color(0xFFFFC2C2);
      case 'cicilan':
        return const Color(0xFFFFE699);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'lunas':
        return Colors.green.shade800;
      case 'belum':
        return Colors.red.shade800;
      case 'cicilan':
        return Colors.orange.shade800;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Kelola Pembayaran'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Search(),
            Preset.smallSpace,

            // Header Tabel
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD6E4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('NIM',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Nama',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('Prodi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Aksi',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Body Tabel
            Expanded(
              child: Consumer<PembayaranProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.listTagihan.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tidak ada data tagihan pembayaran.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: provider.listTagihan.length,
                    separatorBuilder: (context, index) =>
                        const Divider(color: Colors.black12, height: 1),
                    itemBuilder: (context, index) {
                      final tagihan = provider.listTagihan[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(tagihan.nim,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(tagihan.nama,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(tagihan.prodi,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(tagihan.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tagihan.status,
                                  style: TextStyle(
                                    color: _getStatusTextColor(tagihan.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_note,
                                    color: Color(0xFF1A3D7C), size: 24),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UbahPembayaranPage(tagihan: tagihan),
                                    ),
                                  );
                                  if (result == true) {
                                    provider.fetchTagihan();
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