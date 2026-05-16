import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/utils/config.dart';

class Addbtn extends StatelessWidget {
  const Addbtn({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Container(
        decoration: BoxDecoration(color: Preset.primaryColor, borderRadius: BorderRadius.circular(5)),
        child: IconButton(
          onPressed: () {},
          icon: FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}
