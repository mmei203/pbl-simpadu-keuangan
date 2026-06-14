import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/edit-forms/status_form.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/utils/config.dart';

class UbahStatusPage extends StatelessWidget {
  // 🎯 Terima langsung objek mahasiswa lewat konstruktor murni
  final Mahasiswa mahasiswa;

  const UbahStatusPage({super.key, required this.mahasiswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Ubah Status'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      // Langsung oper ke StatusForm tanpa memanggil ModalRoute.of(context) lagi!
      body: SafeArea(
        child: StatusForm(mahasiswa: mahasiswa),
      ),
    );
  }
}