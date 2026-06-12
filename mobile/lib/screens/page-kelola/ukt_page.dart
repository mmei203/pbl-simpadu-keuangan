import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/models/dummy_mahasiswa.dart';
import 'package:mobile/screens/page-edit/ubah_ukt_page.dart';

class UktPage extends StatefulWidget {
  const UktPage({super.key});

  @override
  State<UktPage> createState() => _UktPageState();
}

class _UktPageState extends State<UktPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cari mahasiswa
            const Search(),
            Preset.smallSpace,

            // --- AWAL TAMPILAN TABEL SESUAI DESAIN ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
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
                      // HEADER TABEL (TETAP / STICKY)
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
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Nama',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Prodi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
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
                                  color: Colors.black,
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
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // BODY DATA TABEL (BISA DI-SCROLL)
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero, 
                          shrinkWrap:false,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: dummyMahasiswa.length,
                          itemBuilder: (context, index) {
                            final mhs = dummyMahasiswa[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // NIM
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
                                  // Nama
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      mhs.nama,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  // Prodi
                                  Expanded(
                                    flex: 4,
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
                                  // UKT
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
                                  // Aksi
                                  Expanded(
                                    flex: 2,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UbahUktPage(mahasiswa: mhs),
                                            ),
                                          );
                                          if (result == true) {
                                            setState(() {});
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
              ),
            ),
            // --- AKHIR TAMPILAN TABEL ---
          ],
        ),
      ),
    );
  }
}
