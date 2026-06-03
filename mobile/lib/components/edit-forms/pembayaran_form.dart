import 'package:flutter/material.dart';
import 'package:mobile/components/date_picker.dart';
import 'package:mobile/components/detail_pembayaran.dart';
import 'package:mobile/utils/config.dart';

class PembayaranForm extends StatelessWidget {
  const PembayaranForm({super.key});

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

              // total pembayaran
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Total Tagihan'),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rp. '),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: '1.000.000',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // jumlah bayar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Jumlah Bayar'),
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rp. '),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      hintText: '1.000.000',
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // sisa tagihan (pake operasi total tagihan - bayar = sisa bayar), READ-ONLY BIAR GABISA DI OTAK ATIK
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Total Tagihan'),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Rp. '),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        minHeight: 0,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Metode Pembayaran
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Metode Pembayaran'),
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
                    hintText: 'Pilih Metode pembayaran',
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'bank_btn', label: 'BTN'),
                    ],
                  ),
                ],
              ),

              // Tanggal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tanggal'),
                  TanggalPopup(),
                ],
              ),

              // Jatuh Tempo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jatuh Tempo'),
                  TanggalPopup(),
                ],
              ),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  Text('Status Pembayaran'),
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
                    hintText: 'Berhasil / Pending',
                    dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'berhasil', label: 'Berhasil'),
                      DropdownMenuEntry(value: 'pending', label: 'Pending'),
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
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DetailPembayaran();
                    },
                  );
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
