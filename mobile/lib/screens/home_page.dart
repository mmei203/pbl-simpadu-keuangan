import 'package:flutter/material.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/utils/text.dart';

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
        leadingWidth: 70,
        elevation: 0,
        leading: Container(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Image.asset('assets/logo.png'),
        ),
        centerTitle: true,
        title: Text(
          'SIMPADU',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
    );
  }
}