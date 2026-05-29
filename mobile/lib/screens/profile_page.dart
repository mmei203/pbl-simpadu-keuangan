import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile/components/popup.dart';
import 'package:mobile/components/profile_card.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().loggedInUser;
    return Scaffold(
      backgroundColor: Preset.primaryColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: FaIcon(FontAwesomeIcons.angleLeft),
        ),
        // title
        title: Text('Profile'),
        backgroundColor: Preset.primaryColor,
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Preset.primaryColor,
            padding: EdgeInsets.only(bottom: 70),
            child: SizedBox(height: 10),
          ),
          Expanded(
            child: ProfileCard(
              name:
                  user?.name
                      .split(' ')
                      .map((w) => w[0].toUpperCase() + w.substring(1))
                      .join(' ') ??
                  'Admin',
              role: 'role admin', // nanti get role
              email: 'email atmin', //nanti get email
              imageUrl: 'https://i.pravatar.cc/150?img=3',
              onLogout: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Popup();
                  },
                );
                print('AK NAK LOGOUT');
              },
              onChangePhoto: () {},
            ),
          ),
        ],
      ),
    );
  }
}
