import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel/header.dart';
import 'package:mobile/utils/config.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
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
        title: Text('Kelola Pembayaran'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // cari mahasiswa
            Search(),
            ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, 'pembayaranform');
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
            Preset.smallSpace,
            // tabel
            // header tabel
            HeaderTabel(label: 'Status'),
            // body tabel
            
          ],
        ),
      ),
    );
  }
}