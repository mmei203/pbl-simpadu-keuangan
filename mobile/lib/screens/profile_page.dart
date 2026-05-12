import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Preset.secondaryColor,
      body: Center(child: Text('Profile Page')),
    );
  }
}