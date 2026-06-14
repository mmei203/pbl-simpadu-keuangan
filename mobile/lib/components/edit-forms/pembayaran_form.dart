import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/tagihan.dart';
import 'package:mobile/providers/pembayaran_provider.dart';

class PembayaranForm extends StatefulWidget {
  final TagihanModel tagihan;
  const PembayaranForm({Key? key, required this.tagihan}) : super(key: key);

  @override
  State<PembayaranForm> createState() => _PembayaranFormState();
}

class _PembayaranFormState extends State<PembayaranForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  late DateTime _tanggalBayar;
  late DateTime _jatuhTempo;

  final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  final _formatTanggal = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _tanggalBayar = widget.tagihan.tglBayar != null
        ? DateTime.tryParse(widget.tagihan.tglBayar!) ?? DateTime.now()
        : DateTime.now();

    _jatuhTempo = widget.tagihan.tglJatuhTempo != null
        ? DateTime.tryParse(widget.tagihan.tglJatuhTempo!) ??
            DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));
  }

  Future<void> _pilihTanggal({required bool isJatuhTempo}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isJatuhTempo ? _jatuhTempo : _tanggalBayar,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isJatuhTempo) {
          _jatuhTempo = picked;
        } else {
          _tanggalBayar = picked;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'ID_TAGIHAN': widget.tagihan.id,
      'ID_KEUANGAN_MHS': widget.tagihan.idKeuanganMhs,
      'TOTAL_TAGIHAN': widget.tagihan.totalTagihan,
      'STATUS_BAYAR': widget.tagihan.status,
      'TGL_BAYAR': _tanggalBayar.toIso8601String(),
      'TGL_JATUH_TEMPO': _jatuhTempo.toIso8601String(),
    };

    setState(() => _isSubmitting = true);

    final provider = Provider.of<PembayaranProvider>(context, listen: false);
    bool success = await provider.simpanPembayaran(widget.tagihan.id, payload);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Data pembayaran berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );
      provider.fetchTagihan();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Gagal memperbarui data pembayaran.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget field read-only
  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(value,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // Widget field tanggal
  Widget _tanggalField(String label, DateTime value, bool isJatuhTempo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pilihTanggal(isJatuhTempo: isJatuhTempo),
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTanggal.format(value),
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.calendar_today,
                    size: 18, color: Colors.black54),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.tagihan;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NIM (read only)
          _readOnlyField('NIM', t.nim),

          // Nama Mahasiswa (read only)
          _readOnlyField('Nama Mahasiswa', t.nama),

          // Total UKT (read only)
          _readOnlyField(
              'Total UKT', _formatRupiah.format(t.totalTagihan)),

          // Terbayar (read only)
          _readOnlyField('Terbayar', _formatRupiah.format(t.terbayar)),

          // Sisa (read only)
          _readOnlyField('Sisa', _formatRupiah.format(t.sisa)),

          // Cicilan ke (read only)
          _readOnlyField(
              'Cicilan ke', t.nomorCicilan?.toString() ?? '-'),

          // Tanggal (editable)
          _tanggalField('Tanggal', _tanggalBayar, false),

          // Jatuh Tempo (editable)
          _tanggalField('Jatuh tempo', _jatuhTempo, true),

          const SizedBox(height: 12),

          // Tombol Simpan
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Simpan',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}