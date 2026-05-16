import 'package:flutter/material.dart';

class StatusDropdown extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const StatusDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            style: const TextStyle(color: Colors.black54, fontSize: 14),
            onChanged: onChanged,
            items: const [
              DropdownMenuItem(value: "Semua", child: Text("Status")),
              DropdownMenuItem(value: "Aktif", child: Text("Aktif")),
              DropdownMenuItem(value: "Nonaktif", child: Text("Nonaktif")),
            ],
          ),
        ),
      ),
    );
  }
}