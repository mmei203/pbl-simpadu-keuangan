import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/screens/page-edit/tambah_cicilan_page.dart';
import 'package:mobile/screens/page-edit/ubah_beasiswa_page.dart';
import 'package:mobile/screens/page-edit/ubah_cicilan_page.dart';
import 'package:mobile/screens/page-edit/ubah_pembayaran_page.dart';
import 'package:mobile/screens/page-edit/ubah_status_page.dart';
import 'package:mobile/screens/page-edit/ubah_ukt_page.dart';
import 'package:mobile/screens/page-kelola/beasiswa_page.dart';
import 'package:mobile/screens/page-kelola/cicilan_page.dart';
import 'package:mobile/screens/page-kelola/pembayaran_page.dart';
import 'package:mobile/screens/page-kelola/status_page.dart';
import 'package:mobile/screens/page-kelola/ukt_page.dart';
import 'package:mobile/screens/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().getAllUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      title: 'Admin Keuangan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: Preset.primaryColor,
          border: Preset.outlinedBorder,
          focusedBorder: Preset.focusBorder,
        )
      ),

      // routes
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        'home': (context) => const HomePage(),
        'profile': (context) => const ProfilePage(),
        'ukt': (context) => const UktPage(),
        'status':(context) => const StatusPage(),
        'beasiswa':(context) => const BeasiswaPage(),
        'pembayaran':(context) => const PembayaranPage(),
        'cicilan':(context) => const CicilanPage(),
        // ubah
        'uktform':(context) => const UbahUktPage(),
        'statusform':(context) => const UbahStatusPage(),
        'pembayaranform':(context) => const UbahPembayaranPage(),
        'ubahcicilanform':(context) => const UbahCicilanPage(),
        'cicilanform':(context) => const TambahCicilanPage(),
        'beasiswaform':(context) => const UbahBeasiswaPage(),
      },
    );
  }
}
