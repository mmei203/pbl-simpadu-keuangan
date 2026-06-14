import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. Tambahkan import provider
import 'package:mobile/utils/config.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/providers/ukt_provider.dart'; // 2. Tambahkan import provider kamu

class UktForm extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const UktForm({super.key, required this.mahasiswa});

  @override
  State<UktForm> createState() => _UktFormState();
}

class _UktFormState extends State<UktForm> {
  late TextEditingController _nimController;
  late TextEditingController _namaController;
  String? _selectedUkt;

  @override
  void initState() {
    super.initState();
    _nimController = TextEditingController(text: widget.mahasiswa.nim);
    _namaController = TextEditingController(text: widget.mahasiswa.nama);

    String currentUkt = widget.mahasiswa.ukt.replaceAll(' ', '_').toLowerCase();
    _selectedUkt = currentUkt;
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  const Text('NIM'),
                  TextField(
                    controller: _nimController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  const Text('Nama Mahasiswa'),
                  TextField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Golongan UKT (Dropdown)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  const Text('Golongan UKT'),
                  DropdownMenu<String>(
                    initialSelection: _selectedUkt,
                    width: double.infinity,
                    inputDecorationTheme: InputDecorationTheme(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onSelected: (String? value) {
                      setState(() {
                        _selectedUkt = value;
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'Gol 1', label: 'Golongan 1'),
                      DropdownMenuEntry(value: 'Gol 2', label: 'Golongan 2'),
                      DropdownMenuEntry(value: 'Gol 3', label: 'Golongan 3'),
                      DropdownMenuEntry(value: 'Gol 4', label: 'Golongan 4'),
                      DropdownMenuEntry(value: 'Gol 5', label: 'Golongan 5'),
                    ],
                  ),
                ],
              ),

              // Button Simpan (PERBAIKAN LOGIKA DI SINI)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_selectedUkt != null) {
                    // Tampilkan loading dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    // 2. Paket 'provider' dan 'ukt_provider' sekarang DIGUNAKAN (Warning 2 & 3 Hilang)
                    final uktProvider = Provider.of<UktProvider>(
                      context,
                      listen: false,
                    );
                    final IsBerhasil = await uktProvider.updateUktMahasiswa(
                      widget
                          .mahasiswa, // 🎯 Kirim objek mahasiswa utuh, bukan cuma .nim
                      _selectedUkt!, // Kirim ID Kategori baru dari dropdown
                    );

                    // Tutup loading dialog setelah proses asinkronus selesai
                    if (context.mounted) Navigator.of(context).pop();

                    if (IsBerhasil) {
                      // Notifikasi sukses jika berhasil terintegrasi dengan API
                      const snackBar = SnackBar(
                        duration: Duration(milliseconds: 800),
                        content: Text(
                          'Data telah berhasil diperbarui ke server',
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        // Kembali ke UktPage dengan status true untuk memicu reload UI
                        Navigator.of(context).pop(true);
                      }
                    } else {
                      // Notifikasi gagal jika ada error dari API
                      final errorSnackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          uktProvider.errorMessage.isNotEmpty
                              ? uktProvider.errorMessage
                              : 'Gagal memperbarui data.',
                        ),
                      );
                      if (context.mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(errorSnackBar);
                    }
                  }
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
