import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/utils/config.dart';

class TanggalPopup extends StatefulWidget {
  const TanggalPopup({super.key});

  @override
  State<TanggalPopup> createState() => _TanggalPopupState();
}

class _TanggalPopupState extends State<TanggalPopup> {
  final TextEditingController _dateController = TextEditingController();

  Future<void> _pilihTanggal(BuildContext context) async {
    final DateTime? tanggalDipilih = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(30, 54, 138, 100),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Preset.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            dialogTheme: DialogThemeData(
              insetPadding: EdgeInsets.all(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (tanggalDipilih != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(tanggalDipilih);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),

        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _pilihTanggal(context),
          style: TextStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(
            hintText: 'Pilih Tanggal',
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: Colors.black,
              size: 20,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black12),
            ),
          ),
        ),
      ],
    );
  }
}
