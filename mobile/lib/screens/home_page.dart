import 'package:flutter/material.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<UserProvider>().getAllUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = context.watch<UserProvider>();

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

      // body
      body: ListView.builder(
        itemCount: userProvider.data?.length ?? 0,
        itemBuilder: (BuildContext context, int index) {
          final item = userProvider.data![index];
          return Card(child: ListTile(title: Text('${item.name}')));
        },
      ),
    );
  }
}
