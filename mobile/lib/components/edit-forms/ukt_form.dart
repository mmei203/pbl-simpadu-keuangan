import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/models/dummy_mahasiswa.dart';

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
    
    // Sinkronisasi format dummy data ("UKT 1") dengan value dropdown entries
    _selectedUkt = widget.mahasiswa.ukt.replaceAll(' ', '_').toLowerCase(); 
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
              // NIM (Read Only)
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

              // Nama (Read Only)
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
                      alignLabelWithHint: false,
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
                      DropdownMenuEntry(value: 'ukt_1', label: 'UKT 1'),
                      DropdownMenuEntry(value: 'ukt_2', label: 'UKT 2'),
                      DropdownMenuEntry(value: 'ukt_3', label: 'UKT 3'),
                      DropdownMenuEntry(value: 'ukt_4', label: 'UKT 4'),
                      DropdownMenuEntry(value: 'ukt_5', label: 'UKT 5'),
                    ],
                  ),
                ],
              ),

              // Button Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Aksi update data dummy lokal
                  if (_selectedUkt != null) {
                    // Mengembalikan format 'ukt_1' menjadi 'UKT 1' kembali ke model data
                    String formattedUkt = _selectedUkt!.replaceAll('_', ' ').toUpperCase();
                    widget.mahasiswa.ukt = formattedUkt;
                  }

                  // Notifikasi sukses
                  final snackBar = const SnackBar(
                    duration: Duration(milliseconds: 800),
                    content: Text('Data telah disimpan'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);

                  // Kembali ke UktPage sambil membawa status "true" agar UI di-refresh
                  Navigator.of(context).pop(true);
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