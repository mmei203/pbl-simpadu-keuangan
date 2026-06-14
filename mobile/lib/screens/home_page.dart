import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/menu_card.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/models/dummy_mahasiswa.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().loggedInUser;

    int totalMahasiswa = dummyMahasiswa.length;

    int sudahBayar = dummyMahasiswa.where((m) => m.ukt == 'UKT 1').length;
    int sedangMencicil = dummyMahasiswa.where((m) => m.ukt == 'UKT 2').length;
    int belumBayar = dummyMahasiswa.where((m) => m.ukt == 'UKT 3').length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 65,

        // logo simpadu
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(child: Image.asset('assets/logo.png')),
        ),

        // Tulisan simpadu
        centerTitle: true,
        title: Text(
          'SIMPADU',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),

        // notif & profile
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'notif');
                  },
                  icon: FaIcon(FontAwesomeIcons.clockRotateLeft, size: 24),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'profile');
                  },
                  icon: Icon(Icons.account_circle_outlined),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),

      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_ukt.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // sambutan atmin
                      SizedBox(
                        child: SizedBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppText.myText['welcome']!),
                              Text(
                                user?.name
                                        .split(' ')
                                        .map(
                                          (w) =>
                                              w[0].toUpperCase() +
                                              w.substring(1),
                                        )
                                        .join(' ') ??
                                    'Admin',
                                style: GoogleFonts.poppins(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Preset.smallSpace,

                      // Card Mahasiswa
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        childAspectRatio:
                            1.4, // Rasio keidealan bentuk kotak card statistik
                        children: [
                          _buildStatCard(
                            title: 'Total Mahasiswa',
                            count: totalMahasiswa.toString(),
                            backgroundColor: Preset.primaryColor,
                          ),
                          _buildStatCard(
                            title: 'Sudah Bayar',
                            count: sudahBayar.toString(),
                            backgroundColor: Preset.saveColor,
                          ),
                          _buildStatCard(
                            title: 'Sedang Mencicil',
                            count: sedangMencicil.toString(),
                            backgroundColor: Preset.editColor,
                          ),
                          _buildStatCard(
                            title: 'Belum Bayar',
                            count: belumBayar.toString(),
                            backgroundColor: Preset.errorColor,
                          ),
                        ],
                      ),

                      Preset.smallSpace,
                      Preset.smallSpace,

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.2,
                        children: [
                          MenuCard(
                            title: 'UKT',
                            icon: FontAwesomeIcons.creditCard,
                            color: Preset.primaryColor,
                            onTap: () {
                              Navigator.pushNamed(context, 'ukt');
                              print('Pindah ke halaman UKT');
                            },
                          ),
                          MenuCard(
                            title: 'Status Mahasiswa',
                            icon: FontAwesomeIcons.user,
                            color: const Color.fromRGBO(15, 118, 110, 1),
                            onTap: () {
                              Navigator.pushNamed(context, 'status');
                              print('Pindah ke halaman status');
                            },
                          ),
                          MenuCard(
                            title: 'Penerimaan Pembayaran',
                            icon: FontAwesomeIcons.dollarSign,
                            color: const Color.fromRGBO(22, 163, 74, 1),
                            onTap: () {
                              Navigator.pushNamed(context, 'pembayaran');
                              print('Pindah ke halaman Pembayaran');
                            },
                          ),
                          MenuCard(
                            title: 'Cicilan',
                            icon: FontAwesomeIcons.clock,
                            color: const Color.fromRGBO(234, 88, 12, 1),
                            onTap: () {
                              Navigator.pushNamed(context, 'cicilan');
                              print('Pindah ke halaman Cicilan');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Center(
            child: Text(
              count,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 2,
          ), // Memberikan sedikit padding bawah seimbang
        ],
      ),
    );
  }
}
