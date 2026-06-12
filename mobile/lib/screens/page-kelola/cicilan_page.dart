import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/utils/config.dart';

class CicilanPage extends StatefulWidget {
  const CicilanPage({super.key});

  @override
  State<CicilanPage> createState() => _CicilanPageState();
}

class _CicilanPageState extends State<CicilanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // back button
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft),
        ),
        // title
        title: Text('Kelola Cicilan'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cari mahasiswa & tambah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                Search(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, 'cicilanform');
                  },
                  label: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Preset.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            Preset.smallSpace,
            // tabel
            // header tabel
            // body tabel
          ],
        ),
      ),
    );
  }
}
