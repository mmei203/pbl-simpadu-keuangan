import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Search extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSearch;

  const Search({super.key, this.controller, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        width: 200,
        height: 50,
        child: TextField(
          controller: controller,
          onSubmitted: (_) => onSearch!(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            contentPadding: EdgeInsetsGeometry.symmetric(horizontal: 10),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
            hint: Text(
              'Cari Mahasiswa ...',
              style: TextStyle(color: Colors.grey),
              softWrap: false,
            ),
            suffixIconColor: Colors.grey,
            suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [FaIcon(FontAwesomeIcons.magnifyingGlass)],
            ),
          ),
        ),
      ),
    );
  }
}
