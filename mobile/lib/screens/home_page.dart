import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/components/cards.dart';
import 'package:mobile/components/menu_card.dart';
import 'package:mobile/utils/config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // list fitur

  // dummy data card mahasiswa
  final List<Map<String, dynamic>> _dummy = [
    {'title': 'Total Mahasiswa', 'value': '156', 'color': Preset.primaryColor},
    {'title': 'Sudah Bayar', 'value': '156', 'color': Preset.saveColor},
    {'title': 'Sedang Mencicil', 'value': '156', 'color': Preset.editColor},
    {'title': 'Belum Bayar', 'value': '156', 'color': Preset.errorColor},
  ];

  void updateData() {
    setState(() {
      // Logika untuk mengubah data, contoh:
      _dummy[0]['value'] = '200';
    });
  }

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
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined),
                  iconSize: 30,
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.account_circle_outlined),
                  iconSize: 30,
                ),
              ],
            ),
          ),
        ],
      ),

      body: ListView(
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
                              'Atmin Member',
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
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _dummy.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (context, index) {
                        final item = _dummy[index];

                        return CustomDashboardCard(
                          title: item['title'],
                          value: item['value'],
                          color: item['color'],
                        );
                      },
                    ),

                    Preset.smallSpace,

                    // Notifikasi
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(255, 238, 170, 100),
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                      child: Column(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul
                          Row(
                            spacing: 4,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Color.fromRGBO(245, 158, 11, 100),
                                size: 30,
                              ),
                              Text(
                                'Pemberitahuan',
                                style: GoogleFonts.poppins(
                                  color: Color.fromRGBO(146, 64, 14, 100),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          // isi pemberitahuan
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            child: Column(
                              spacing: 4,
                              children: [
                                Text(
                                  'Notif 1',
                                  style: GoogleFonts.poppins(
                                    color: Color.fromRGBO(146, 64, 14, 100),
                                  ),
                                ),
                                Text(
                                  'Notif 2',
                                  style: GoogleFonts.poppins(
                                    color: Color.fromRGBO(146, 64, 14, 100),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Preset.smallSpace,

                    // fitur Layanan
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                            double itemWidth = (constraints.maxWidth - 20) / 2;

                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: itemWidth,
                                  child: MenuCard(
                                    title: 'UKT',
                                    icon: FontAwesomeIcons.creditCard,
                                    color: Color.fromRGBO(37, 99, 235, 1),
                                    onTap: () {
                                      print('Pindah ke halaman UKT');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: MenuCard(
                                    title: 'Beasiswa',
                                    icon: FontAwesomeIcons.award,
                                    color: Color.fromRGBO(124, 58, 237, 1),
                                    onTap: () {
                                      print('Pindah ke halaman Beasiswa');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: MenuCard(
                                    title: 'Status Mahasiswa',
                                    icon: FontAwesomeIcons.user,
                                    color: Color.fromRGBO(15, 118, 110, 1),
                                    onTap: () {
                                      print('Pindah ke halaman status');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: MenuCard(
                                    title: 'Penerimaan Pembayaran',
                                    icon: FontAwesomeIcons.dollarSign,
                                    color: Color.fromRGBO(22, 163, 74, 1),
                                    onTap: () {
                                      print('Pindah ke halaman Pembayaran');
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: itemWidth,
                                  child: MenuCard(
                                    title: 'Cicilan',
                                    icon: FontAwesomeIcons.clock,
                                    color: Color.fromRGBO(234, 88, 12, 1),
                                    onTap: () {
                                      print('Pindah ke halaman Cicilan');
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
