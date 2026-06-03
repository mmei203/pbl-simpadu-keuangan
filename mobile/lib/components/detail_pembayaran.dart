import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class DetailPembayaran extends StatelessWidget {
  const DetailPembayaran({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          IconButton(onPressed: (){}, icon: Icon(Icons.exit_to_app_rounded)),
          Text('Transaksi Berhasil'),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          // Tanggal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tanggal', style: TextStyle(fontSize: 17)),
              Text('Get tanggal melakukan transaksi'),
            ],
          ),

          // Nama Mahasiswa
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nama Mahasiswa', style: TextStyle(fontSize: 17)),
              Text('Ambil Nama Mahasiswa'),
            ],
          ),

          // Metode Pembayaran
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Metode Pembayaran', style: TextStyle(fontSize: 17)),
              Text('Get metode pembayaran'),
            ],
          ),

          // Jumlah Dibayar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Jumlah Dibayar', style: TextStyle(fontSize: 17)),
              Text('Get jumlah yang dibayar'),
            ],
          ),

          // Biaya admin
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Biaya admin', style: TextStyle(fontSize: 17)),
              Text('default = 2.000'),
            ],
          ),

          // Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: TextStyle(fontSize: 17)),
              Text('Hitung Jumlah Bayar + Biaya Admin'),
            ],
          ),

          // Cetak btn
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
                content: Text('Detail telah dicetak'),
              );
              ScaffoldMessenger.of(context).showSnackBar(result);
              Navigator.of(context).pop();
            },
            child: Text(
              'Cetak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}
