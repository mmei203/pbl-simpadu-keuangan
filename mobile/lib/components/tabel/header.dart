import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class HeaderTabel extends StatelessWidget {
  const HeaderTabel({super.key, required this.label});

  final String nim = 'NIM';
  final String nama = 'Nama';
  final String jurusan = 'Jurusan';
  final String label; // bisa diisi sama ukt, status, beasiswa, sisa cicilan
  final String action = 'Aksi';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Preset.secondaryColor,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nim),
          Text(nama),
          Text(jurusan),
          Text(label),
          Text(action),
        ],
      ),
    );
  }
}
