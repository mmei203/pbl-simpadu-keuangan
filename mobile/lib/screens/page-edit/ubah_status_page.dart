import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/edit-forms/status_form.dart';
import 'package:mobile/utils/config.dart';

class UbahStatusPage extends StatelessWidget {
  const UbahStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // back button
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft),
        ),
        // title
        title: Text('Ubah Status'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusForm(),
        ],
      ),
    );
  }
}