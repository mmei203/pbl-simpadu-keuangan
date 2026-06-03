import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel/header.dart';
import 'package:mobile/utils/config.dart';

class BeasiswaPage extends StatefulWidget {
  const BeasiswaPage({super.key});

  @override
  State<BeasiswaPage> createState() => _BeasiswaPageState();
}

class _BeasiswaPageState extends State<BeasiswaPage> {
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
        title: Text('Kelola Beasiswa'),
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
                    Navigator.pushNamed(context, 'beasiswaform');
                  },
                  label: Icon(Icons.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Preset.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            Preset.smallSpace,
            // tabel
            // header tabel
            HeaderTabel(label: 'Beasiswa'),
            // body tabel
          ],
        ),
      ),
    );
  }
}
