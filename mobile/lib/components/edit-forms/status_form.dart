import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class StatusForm extends StatelessWidget {
  const StatusForm({super.key});

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

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Status'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    spacing: 15,
                    // Radio 
                    children: [
                      // Aktif
                      Row(
                        spacing: (-10),
                        children: [
                          Radio(value: 1),
                          Text('Aktif'),
                        ],
                      ),

                      // Nonaktif
                      Row(
                        spacing: (-10),
                        children: [
                          Radio(value: 2),
                          Text('Nonaktif'),
                        ],
                      )
                    ],
                  )
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
