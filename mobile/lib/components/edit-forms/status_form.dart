import 'package:flutter/material.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/services/status_service.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/status_provider.dart';
import 'package:mobile/providers/history_provider.dart';
import 'package:mobile/models/history.dart';


class StatusForm extends StatefulWidget {
  final Mahasiswa mahasiswa;

  const StatusForm({super.key, required this.mahasiswa});

  @override
  State<StatusForm> createState() => _StatusFormState();
}

class _StatusFormState extends State<StatusForm> {
  final StatusService _statusService = StatusService();

  late TextEditingController _nimController;
  late TextEditingController _namaController;

  String? _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nimController = TextEditingController(text: widget.mahasiswa.nim);
    _namaController = TextEditingController(text: widget.mahasiswa.nama);
    _selectedStatus = widget.mahasiswa.ukt.toUpperCase() == 'AKTIF'
        ? 'AKTIF'
        : 'NONAKTIF';
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  void _submitData() async {
    setState(() {
      _isLoading = true;
    });

    String idKategori = 'KAT056'; 
    String semester = '1';
    String beasiswa = 'Tidak';
    bool isSuccess = await _statusService.updateStatus(
      widget.mahasiswa.id,
      widget.mahasiswa.id,
      _selectedStatus!,             
      idKategori: idKategori,
      semester: semester,
      beasiswa: beasiswa,
    );

    setState(() {
      _isLoading = false;
    });

    if (isSuccess) {
      final now = DateTime.now();
      final tanggal = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final historyEntry = HistoryPembayaran(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: widget.mahasiswa.nama,
        nim: widget.mahasiswa.nim,
        tipe: 'Status diubah menjadi ${_selectedStatus!}',
        nominal: '-',
        tanggal: tanggal,
      );

      try {
        await Provider.of<HistoryProvider>(context, listen: false)
            .addHistory(historyEntry);
      } catch (e) {
        debugPrint('Gagal menyimpan history Status: $e');
      }

      final snackBar = const SnackBar(
        duration: Duration(milliseconds: 800),
        content: Text('Status mahasiswa berhasil diperbarui'),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      
      Provider.of<StatusProvider>(context, listen: false).fetchStatusMahasiswa();
      
      Navigator.of(context).pop(true);
    } else {
      final snackBar = const SnackBar(
        duration: Duration(milliseconds: 1500),
        content: Text('Gagal memperbarui status ke server'),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  const Text(
                    'NIM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _nimController,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
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
                  const Text(
                    'Nama Mahasiswa',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: _namaController,
                    readOnly: true,
                    decoration: InputDecoration(
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),

              // Status (Radio Button)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: 'AKTIF',
                            groupValue: _selectedStatus,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          const Text('Aktif'),
                        ],
                      ),

                      // Pilihan: Nonaktif
                      Row(
                        children: [
                          Radio<String>(
                            value: 'NONAKTIF',
                            groupValue: _selectedStatus,
                            visualDensity: const VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                          const Text('Nonaktif'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Button Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Preset.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading ? null : _submitData,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
