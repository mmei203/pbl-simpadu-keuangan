import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Preset.primaryColor,
        elevation: 0,
        toolbarHeight: 65,

        // logo simpadu
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            child: Image.asset('assets/logo.png'),
          ),
        ),

        // Tulisan simpadu
        centerTitle: true,
        title: Text(
          'SIMPADU',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold
          )
        ),

        // notif & profile
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 30,
                ),
                Icon(
                  Icons.account_circle_rounded,
                  size: 30,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}