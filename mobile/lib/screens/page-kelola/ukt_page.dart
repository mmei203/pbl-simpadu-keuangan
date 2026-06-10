import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/search.dart';
import 'package:mobile/components/tabel/tabel_ukt.dart';
import 'package:mobile/providers/mahasiswa_provider.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

class UktPage extends StatefulWidget {
  const UktPage({super.key});

  @override
  State<UktPage> createState() => _UktPageState();
}

class _UktPageState extends State<UktPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<MahasiswaProvider>().fetchAllMahasiswa(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mahasiswaProvider = context.watch<MahasiswaProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft),
        ),
        title: const Text('Kelola UKT'),
        elevation: 2,
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Search(
              controller: _searchController,
              onSearch: () {
                final query = _searchController.text.trim().toLowerCase();
                if (query.isEmpty) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cari: $query')), 
                );
              },
            ),
            Preset.smallSpace,
            Expanded(
              child: TabelUkt(
                mahasiswa: mahasiswaProvider.mahasiswa,
                isLoading: mahasiswaProvider.isLoading,
                onRefresh: () => mahasiswaProvider.fetchAllMahasiswa(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
