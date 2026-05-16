import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/dropdown.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/utils/config.dart';

class StatusmhsPage extends StatefulWidget {
  const StatusmhsPage({super.key});

  @override
  State<StatusmhsPage> createState() => _StatusmhsPageState();
}

class _StatusmhsPageState extends State<StatusmhsPage> {
  String _selectedStatus = "Semua";
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
    List<Mahasiswa> filteredData = dummyStatus;
    if (_selectedStatus != "Semua") {
      filteredData = dummyStatus
          .where((mhs) => mhs.status == _selectedStatus)
          .toList();
    }

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
        title: const Text('Kelola Status Mahasiswa'),
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
                  // dropdown
                  Expanded(
                    child: Align(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
                        child: StatusDropdown(
                          selectedValue: _selectedStatus,
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value ?? 'Semua';
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabelMahasiswa(data: filteredData, labelStatus: "Status"),
            ),
          ],
        ),
      ),
    );
  }
}
