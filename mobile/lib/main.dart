import 'package:flutter/material.dart';
import 'package:mobile/main_layout.dart';
import 'package:mobile/screens/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Admin Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false
      ),

      // routes
      initialRoute : '/',
      routes: {
        '/' : (context) => const LoginPage(),
        'main' : (context) => const MainLayout()
      },
    );
  }
}
