import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class DetailPembayaran extends StatelessWidget {
  final String tanggal;
  final String nama;
  final String metode;
  final double jumlahBayar;
  final double biayaAdmin = 2000.0;

  const DetailPembayaran({
    super.key,
    required this.tanggal,
    required this.nama,
    required this.metode,
    required this.jumlahBayar,
  });

  @override
  Widget build(BuildContext context) {
    final double totalTransaksi = jumlahBayar + biayaAdmin;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(), 
            icon: const Icon(Icons.exit_to_app_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 5),
          const Text('Transaksi Berhasil', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tanggal', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(tanggal.isNotEmpty ? tanggal : '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nama Mahasiswa', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Metode Pembayaran', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(metode.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jumlah Dibayar', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Rp. ${jumlahBayar.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Biaya admin', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text('Rp. ${biayaAdmin.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 18),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  'Rp. ${totalTransaksi.toStringAsFixed(0)}', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Preset.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  const result = SnackBar(
                    duration: Duration(milliseconds: 800),
                    content: Text('Detail telah dicetak'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(result);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cetak',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}