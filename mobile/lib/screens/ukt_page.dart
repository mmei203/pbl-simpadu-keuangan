import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/utils/config.dart';

class UktPage extends StatefulWidget {
  const UktPage({super.key});

  @override
  State<UktPage> createState() => _UktPageState();
}

class _UktPageState extends State<UktPage> {
  final TextEditingController _searchController = TextEditingController();

  void _executeSearch() {
    String query = _searchController.text;
    if (query.isNotEmpty) {
      print('cari $query');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Preset.backgroundColor,
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () {
            print('kembali ke awal');
            Navigator.pop(context);
          },
        ),
        title: Text('Kelola UKT', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        color: Preset.backgroundColor,
        padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 90),
        child: Column(
          children: [
            // cari mahasiswa
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.65,
                child: SizedBox(
                  height: 45,
                  child: CariMhs(
                    controller: _searchController,
                    onSearch: _executeSearch,
                  ),
                ),
              ),
            ),
            Preset.smallSpace,
            // Tabel UKT
            Expanded(
              child: TabelMahasiswa(data: dummyUKT, labelStatus: "UKT"),
            ),
          ],
        ),
      ),
    );
  }
}
