import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/addbtn.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/utils/config.dart';

class BeasiswaPage extends StatefulWidget {
  const BeasiswaPage({super.key});

  @override
  State<BeasiswaPage> createState() => _BeasiswaPageState();
}

class _BeasiswaPageState extends State<BeasiswaPage> {
  final TextEditingController _searchController = TextEditingController();

  void _executeSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      print('cari $query');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.black,
        elevation: 2,
        backgroundColor: Preset.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Kelola Beasiswa'),
      ),
      backgroundColor: Preset.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8, bottom: 60),
        child: Column(
          children: [
            // Bagian search
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: 0.75,
                        child: SizedBox(
                          height: 45,
                          child: CariMhs(
                            controller: _searchController,
                            onSearch: _executeSearch,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // tambah mhs
                  Addbtn()
                ],
              ),
            ),
            Expanded(
              child: TabelMahasiswa(data: dummyBeasiswa, labelStatus: "Beasiswa"),
            ),
          ],
        ),
      ),
    );
  }
}
