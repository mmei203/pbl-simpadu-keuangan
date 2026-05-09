import 'package:flutter/material.dart';
import 'package:mobile/components/login_form.dart';
import 'package:mobile/utils/config.dart';
import 'package:mobile/utils/text.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Preset.primaryColor,
      body:Center(
        child: SizedBox(
          width: 350,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 25
            ),
            decoration: BoxDecoration(
              color: Preset.secondaryColor,
              borderRadius: BorderRadius.circular(15)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  child: Image.asset('assets/logo.png'),
                ),
                Preset.smallSpace,
                Text(
                  AppText.myText['welcome']!,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800
                  ),
                ),
                Text(
                  AppText.myText['login']!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal
                  ),
                ),
                Preset.smallSpace,
                LoginForm()
              ],
            ),
          ),
        ),
      )
    );
  }
}