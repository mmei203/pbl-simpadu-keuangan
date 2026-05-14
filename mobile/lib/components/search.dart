import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CariMhs extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const CariMhs({super.key, required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSearch(),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hint: Text(
            'Cari Mahasiswa ...',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: InputBorder.none,
          suffixIcon: IconButton(
            onPressed: onSearch,
            icon: FaIcon(FontAwesomeIcons.magnifyingGlass),
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
