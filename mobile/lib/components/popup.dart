import 'package:flutter/material.dart';
import 'package:mobile/screens/login_page.dart';
import 'package:mobile/utils/config.dart';

class Popup extends StatelessWidget {
  const Popup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Center(child: Text('Log Out')),
      content: Text('Anda yakin ingin log out?'),
      actions: [
        Center(
          child: Row(
            spacing: 10,
            children: [
              // yes
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Preset.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  // fungsi clear token blum yh ges
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );

                  print('AK PEGI');
                },
                child: Text('Log Out'),
              ),
              // cancel
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  print('AK KEMBALI');
                },
                child: Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
