import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/edit-forms/ukt_form.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/models/mahasiswa.dart';

class UbahUktPage extends StatelessWidget {
  final Mahasiswa mahasiswa;

  const UbahUktPage({super.key, required this.mahasiswa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(false),
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Ubah UKT'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Melemparkan data mahasiswa ke form edit
          UktForm(mahasiswa: mahasiswa),
        ],
      ),
    );
  }
}