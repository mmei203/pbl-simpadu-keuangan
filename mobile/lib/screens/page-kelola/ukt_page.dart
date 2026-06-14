import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart'; // 1. Wajib Import Provider
import 'package:mobile/components/search.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/providers/ukt_provider.dart'; // 2. Import Provider kamu
import 'package:mobile/screens/page-edit/ubah_ukt_page.dart';

class UktPage extends StatefulWidget {
  const UktPage({super.key});

  @override
  State<UktPage> createState() => _UktPageState();
}

class _UktPageState extends State<UktPage> {
  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi fetch data dari Provider saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UktProvider>(context, listen: false).fetchAllMahasiswa();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Kelola UKT'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 20,
                  bottom: 15,
                ),
                child: const Search(),
              ),

              // 4. Gunakan Consumer untuk memantau perubahan data di UktProvider
              Expanded(
                child: Consumer<UktProvider>(
                  builder: (context, uktProvider, child) {
                    // KONDISI LOADING
                    if (uktProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // KONDISI ERROR
                    if (uktProvider.errorMessage.isNotEmpty) {
                      return Center(
                        child: Text(
                          uktProvider.errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    // KONDISI DATA KOSONG
                    if (uktProvider.listMahasiswa.isEmpty) {
                      return const Center(
                        child: Text('Tidak ada data mahasiswa.'),
                      );
                    }

                    // KONDISI BERHASIL (TAMPILKAN TABEL)
                    return Container(
                      margin: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        bottom: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            // HEADER TABEL
                            Container(
                              color: const Color(0xFFD2E4FF),
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              child: const Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'NIM',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Nama',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Prodi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'UKT',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Aksi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // BODY DATA TABEL
                            Expanded(
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: false,
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: uktProvider.listMahasiswa.length,
                                itemBuilder: (context, index) {
                                  final mhs = uktProvider.listMahasiswa[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 10,
                                    ),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFFE5EDFA),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // NIM - Diubah ke flex: 3 (Sesuai Header)
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            mhs.nim,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // NAMA - Diubah ke flex: 3 (Sesuai Header) agar tidak terpotong sempit
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            mhs.nama,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // PRODI - Diubah ke flex: 3 (Sesuai Header)
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            mhs.prodi.length > 13
                                                ? '${mhs.prodi.substring(0, 13)}..'
                                                : mhs.prodi,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // UKT - Tetap flex: 2 (Sesuai Header)
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            mhs.ukt,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        // AKSI - Tetap flex: 2 (Sesuai Header)
                                        Expanded(
                                          flex: 2,
                                          child: Center(
                                            child: InkWell(
                                              onTap: () async {
                                                final result =
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UbahUktPage(
                                                              mahasiswa: mhs,
                                                            ),
                                                      ),
                                                    );
                                                if (result == true) {
                                                  uktProvider
                                                      .fetchAllMahasiswa();
                                                }
                                              },
                                              child: FaIcon(
                                                FontAwesomeIcons.penToSquare,
                                                color: Preset.primaryColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
