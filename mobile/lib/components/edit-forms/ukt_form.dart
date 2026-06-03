import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class UktForm extends StatelessWidget {
  const UktForm({super.key});

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
                  Text('Nama'),
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

              // Golongan
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Golongan Ukt'),
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
                    hintText: 'Golongan UKT',
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'ukt_1', label: 'UKT 1'),
                      DropdownMenuEntry(value: 'ukt_2', label: 'UKT 2'),
                      DropdownMenuEntry(value: 'ukt_3', label: 'UKT 3'),
                      DropdownMenuEntry(value: 'ukt_4', label: 'UKT 4'),
                      DropdownMenuEntry(value: 'ukt_5', label: 'UKT 5'),
                    ],
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
