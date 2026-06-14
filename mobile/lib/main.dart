import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/providers/status_provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/screens/home_page.dart';
import 'package:mobile/screens/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile/screens/notif_page.dart';
import 'package:mobile/screens/page-edit/ubah_pembayaran_page.dart';
import 'package:mobile/screens/page-kelola/cicilan_page.dart';
import 'package:mobile/screens/page-kelola/pembayaran_page.dart';
import 'package:mobile/screens/page-kelola/status_page.dart';
import 'package:mobile/screens/page-kelola/ukt_page.dart';
import 'package:mobile/providers/ukt_provider.dart';
import 'package:mobile/screens/profile_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

void main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => UktProvider()),
        ChangeNotifierProvider(create: (_) => StatusProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() {
      context.read<UserProvider>().getAllUser();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
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
        ),
      ),

      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        'home': (context) => const HomePage(),
        'profile': (context) => const ProfilePage(),
        'notif': (context) => const HistoryPage(),
        'ukt': (context) => const UktPage(),
        'status': (context) => const StatusPage(),
        'pembayaran': (context) => const PembayaranPage(),
        'cicilan': (context) => const CicilanPage(),
        'pembayaranform': (context) => const UbahPembayaranPage(),
      },
    );
  }
}
