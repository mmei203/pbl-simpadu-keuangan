import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/utils/config.dart';

class TabelMahasiswa extends StatelessWidget {
  final List<Mahasiswa> data;
  final String labelStatus; 

  const TabelMahasiswa({
    super.key,
    required this.data,
    required this.labelStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          // Header Tetap
          _buildHeader(),

          // Isi Tabel yang bisa di-scroll
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1),
                },
                children: data.map((item) => _buildRow(item)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(239, 246, 255, 100),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  _headerText("NIM"),
                  _headerText("Nama"),
                  _headerText("Jurusan"),
                  _headerText(labelStatus),
                  _headerText("Aksi"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildRow(Mahasiswa item) {
    return TableRow(
      children: [
        _cellText(item.nim),
        _cellText(item.nama),
        _cellText(item.jurusan),
        _cellText(item.status),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: FaIcon(
            FontAwesomeIcons.penToSquare,
            color: Preset.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _headerText(String text) => Center(
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontWeight: FontWeight.bold, 
        fontSize: 12
      ),
    ),
  );
  Widget _cellText(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Center(child: Text(text, style: const TextStyle(fontSize: 11))),
  );
}
