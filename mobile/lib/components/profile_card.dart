import 'package:flutter/material.dart';
import 'package:mobile/components/profile_field.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String role;
  final String email;
  final String imageUrl;
  final VoidCallback onLogout;
  final VoidCallback onChangePhoto;

  const ProfileCard({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    required this.imageUrl,
    required this.onLogout,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            child: Padding(
              padding: EdgeInsets.only(top: 70, left: 25, right: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      spacing: 5,
                      children: [Text(
                        name,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold
                        ),
                      ),Text(role)],
                    ),
                  ),
                  SizedBox(height: 20,),
                  // field
                  ProfileField(label: 'Nama', value: name),
                  ProfileField(label: 'Role', value: role),
                  ProfileField(label: 'Email', value: email),
          
                  Spacer(),
          
                  Padding(
                    padding: EdgeInsets.only(bottom: 90),
                    child: Center(
                      child: TextButton.icon(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: onLogout,
                        label: Text('Log Out'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: -45,
          left: 90,
          right: 90,
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
