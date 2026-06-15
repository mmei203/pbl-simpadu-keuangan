// file: pembayaran_form.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:mobile/models/tagihan.dart';
import 'package:mobile/providers/pembayaran_provider.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/models/history.dart';

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
  late String _statusBayar;

  final TextEditingController _nominalCicilanController =
      TextEditingController();

  final _formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp. ',
    decimalDigits: 0,
  );

  final _formatTanggal = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();

    String statusMentah = widget.tagihan.status.trim().toLowerCase();

    if (statusMentah == 'lunas') {
      _statusBayar = 'lunas';
    } else if (statusMentah.contains('cicilan')) {
      _statusBayar = 'cicilan';
    } else {
      _statusBayar = 'belum bayar';
    }

    _tanggalBayar = widget.tagihan.tglBayar != null
        ? DateTime.tryParse(widget.tagihan.tglBayar!) ?? DateTime.now()
        : DateTime.now();

    _jatuhTempo = widget.tagihan.tglJatuhTempo != null
        ? DateTime.tryParse(widget.tagihan.tglJatuhTempo!) ??
              DateTime.now().add(const Duration(days: 30))
        : DateTime.now().add(const Duration(days: 30));

    if (widget.tagihan.nominalCicilan != null) {
      _nominalCicilanController.text = widget.tagihan.nominalCicilan!
          .toStringAsFixed(0);
    } else {
      _nominalCicilanController.text = '0';
    }
  }

  @override
  void dispose() {
    _nominalCicilanController.dispose();
    super.dispose();
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

    int currentCicilanIndex = widget.tagihan.nomorCicilan ?? 0;

    if (_statusBayar == 'cicilan') {
      currentCicilanIndex += 1;
    }

    String statusApi = 'Belum Bayar';
    if (_statusBayar == 'lunas') statusApi = 'LUNAS';
    if (_statusBayar == 'cicilan') statusApi = 'Cicilan';

    final payload = {
      'NO_INVOICE': widget.tagihan.noInvoice ?? '',
      'NAMA_TAGIHAN': widget.tagihan.namaTagihan ?? 'UKT Mahasiswa',
      'NOMOR_CICILAN': currentCicilanIndex,
      'TOTAL_CICILAN': widget.tagihan.totalCicilan ?? 1,
      'NOMINAL_CICILAN': double.tryParse(_nominalCicilanController.text) ?? 0.0,
      'POTONGAN': widget.tagihan.potongan ?? 0.0,
      'TOTAL_TAGIHAN': widget.tagihan.totalTagihan,
      'STATUS_BAYAR': statusApi,
      'TGL_JATUH_TEMPO': _jatuhTempo.toIso8601String(),
      'TGL_BAYAR': _tanggalBayar.toIso8601String(),
    };

    setState(() => _isSubmitting = true);

    final provider = Provider.of<PembayaranProvider>(context, listen: false);
    bool success = false;
    try {
      await provider.simpanPembayaran(widget.tagihan.id, payload);
      success = true;
    } catch (e) {
      success = false;
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pembayaran berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      final Object nomorCicilanBaru =
          payload['NOMOR_CICILAN'] ?? widget.tagihan.nomorCicilan ?? 0;
      final String tipeHistory =
          (payload['STATUS_BAYAR'] != null &&
              payload['STATUS_BAYAR'].toString().toLowerCase().contains(
                'lunas',
              ))
          ? 'Pembayaran Lunas'
          : (payload['STATUS_BAYAR'] != null &&
                payload['STATUS_BAYAR'].toString().toLowerCase().contains(
                  'cicilan',
                ))
          ? 'Cicilan ke-$nomorCicilanBaru'
          : 'Perubahan Data';

      final double nominalDouble = (payload['NOMINAL_CICILAN'] is double)
          ? payload['NOMINAL_CICILAN'] as double
          : double.tryParse((payload['NOMINAL_CICILAN'] ?? '0').toString()) ??
                0.0;

      final String nominalFormatted = _formatRupiah.format(nominalDouble);
      final String tanggal = _formatTanggal.format(DateTime.now());

      final historyEntry = HistoryPembayaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: widget.tagihan.nama,
        nim: widget.tagihan.nim,
        tipe: tipeHistory,
        nominal: nominalFormatted,
        tanggal: tanggal,
      );

      try {
        await Provider.of<HistoryProvider>(
          context,
          listen: false,
        ).addHistory(historyEntry);
      } catch (e) {
      }

      provider.fetchTagihan();
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui data pembayaran.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _readOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _tanggalField(String label, DateTime value, bool isJatuhTempo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _pilihTanggal(isJatuhTempo: isJatuhTempo),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                const Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: Colors.black54,
                ),
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
          _readOnlyField('NIM', t.nim),
          _readOnlyField('Nama Mahasiswa', t.nama),
          _readOnlyField('Total UKT', _formatRupiah.format(t.totalTagihan)),
          _readOnlyField('Terbayar', _formatRupiah.format(t.terbayar)),
          _readOnlyField('Sisa', _formatRupiah.format(t.sisa)),
          _readOnlyField('Cicilan ke', t.nomorCicilan?.toString() ?? '0'),

          const Text(
            'Status Pembayaran',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),

          DropdownButtonFormField<String>(
            value: _statusBayar,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            items: const [
              DropdownMenuItem(
                value: 'belum bayar',
                child: Text('Belum Lunas'),
              ),
              DropdownMenuItem(value: 'cicilan', child: Text('Cicilan')),
              DropdownMenuItem(value: 'lunas', child: Text('Lunas')),
            ],
            onChanged: (value) {
              setState(() {
                _statusBayar = value ?? 'belum bayar';
              });
            },
          ),
          const SizedBox(height: 12),

          const Text(
            'Nominal Pembayaran',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _nominalCicilanController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Masukkan nominal rupiah pembayaran',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              prefixText: 'Rp ',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Nominal pembayaran tidak boleh kosong';
              }
              if (double.tryParse(value) == null) {
                return 'Masukkan format nominal angka yang valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          _tanggalField('Tanggal Transaksi', _tanggalBayar, false),
          _tanggalField('Jatuh Tempo', _jatuhTempo, true),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A3D7C),
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
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Simpan Pembayaran',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
