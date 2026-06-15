import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/models/mahasiswa.dart';
import 'package:mobile/models/history.dart';
import 'package:mobile/providers/ukt_provider.dart';
import 'package:mobile/providers/history_provider.dart';

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

    _selectedUkt = widget.mahasiswa.ukt;
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  const Text('Golongan UKT'),
                  DropdownMenu<String>(
                    initialSelection: _selectedUkt,
                    width: double.infinity,
                    inputDecorationTheme: InputDecorationTheme(
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
                      DropdownMenuEntry(value: 'KAT056', label: 'Golongan 1'),
                      DropdownMenuEntry(value: 'KAT057', label: 'Golongan 2'),
                      DropdownMenuEntry(value: 'KAT058', label: 'Golongan 3'),
                      DropdownMenuEntry(value: 'KAT059', label: 'Golongan 4'),
                      DropdownMenuEntry(value: 'KAT060', label: 'Golongan 5'),
                    ],
                  ),
                ],
              ),

              // Button Simpan
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (_selectedUkt != null) {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    final uktProvider = Provider.of<UktProvider>(
                      context,
                      listen: false,
                    );

                    final isBerhasil = await uktProvider.updateMahasiswaUkt(
                      widget.mahasiswa.id,
                      _selectedUkt!,
                    );

                    if (context.mounted) Navigator.of(context).pop();

                    if (isBerhasil) {
                      final now = DateTime.now();
                      final tanggal =
                          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
                      final historyEntry = HistoryPembayaran(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nama: widget.mahasiswa.nama,
                        nim: widget.mahasiswa.nim,
                        tipe: 'UKT diubah menjadi ${_selectedUkt!}',
                        nominal: '-',
                        tanggal: tanggal,
                      );

                      try {
                        await Provider.of<HistoryProvider>(
                          context,
                          listen: false,
                        ).addHistory(historyEntry);
                      } catch (e) {
                        debugPrint('Gagal menyimpan history Ukt: $e');
                      }

                      const snackBar = SnackBar(
                        duration: Duration(milliseconds: 800),
                        content: Text(
                          'Data telah berhasil diperbarui ke server',
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.of(context).pop(true);
                      }
                    } else {
                      final errorSnackBar = SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          uktProvider.errorMessage.isNotEmpty
                              ? uktProvider.errorMessage
                              : 'Gagal memperbarui data.',
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(errorSnackBar);
                      }
                    }
                  }
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
