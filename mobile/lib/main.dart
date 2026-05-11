import 'package:flutter/material.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/screens/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await dotenv.load();

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
      theme: ThemeData(useMaterial3: false,
      textTheme: GoogleFonts.poppinsTextTheme(
        Theme.of(context).textTheme
      )),

      // routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage()
      },
    );
  }
}
