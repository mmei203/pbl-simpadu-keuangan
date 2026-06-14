import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/models/tagihan.dart'; // Pastikan import model ini ada
import 'package:mobile/components/edit-forms/pembayaran_form.dart';

class UbahPembayaranPage extends StatelessWidget {
  final TagihanModel tagihan; // 🎯 Diubah dari Tagihan ke TagihanModel

  const UbahPembayaranPage({super.key, required this.tagihan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Ubah Pembayaran'),
        backgroundColor: const Color(0xFF1A3D7C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: PembayaranForm(tagihan: tagihan), // Teruskan ke form
        ),
      ),
    );
  }
}