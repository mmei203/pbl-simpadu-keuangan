import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class TambahBeasiswaForm extends StatelessWidget {
  const TambahBeasiswaForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // NIM
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('NIM'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'C030324000',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Nama
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Nama Mahasiswa'),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Thom Yorke',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Beasiswa
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Beasiswa'),
                  DropdownMenu(
                    width: double.infinity,
                    inputDecorationTheme: InputDecorationTheme(
                      alignLabelWithHint: false,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    menuStyle: MenuStyle(
                      maximumSize: WidgetStateProperty.all(
                        Size(250, double.infinity),
                      ),
                    ),
                    hintText: 'Pilih Beasiswa',
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'kip', label: 'KIP'),
                    ],
                  ),
                ],
              ),

              // Nominal Potongan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Nominal Potongan (%)'),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '100',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final result = SnackBar(
                    duration: Duration(milliseconds: 800),
                    content: Text('Data telah disimpan'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(result);
                },
                child: Text(
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