import 'package:flutter/material.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // FORM KEY
  final _formKey = GlobalKey<FormState>();

  // CONTROLLER
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  // SERVICE
  final UserService userService = UserService();

  // SHOW / HIDE PASSWORD
  bool obsecurePass = true;

  @override
  void initState() {
    super.initState();

    // DEFAULT VALUE
    _emailController.text = 'tim4@admin.com';
    _passController.text = 'pass#tim4';
  }

  // LOGIN FUNCTION
  Future<void> login() async {
    UserRequests userRequests = UserRequests(
      email: _emailController.text,
      password: _passController.text,
    );

    bool success = await userService.createUser(userRequests);

    if (success) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email atau Password salah'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // EMAIL
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.black54,

            decoration: const InputDecoration(
              border: OutlineInputBorder(),

              hintText: 'Gmail',
              labelText: 'Username',

              alignLabelWithHint: true,

              prefixIcon: Icon(Icons.email),
            ),
          ),

          Preset.smallSpace,

          // PASSWORD
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.black54,

            obscureText: obsecurePass,

            decoration: InputDecoration(
              border: const OutlineInputBorder(),

              hintText: 'Password',
              labelText: 'Password',

              alignLabelWithHint: true,

              prefixIcon: const Icon(Icons.lock),

              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },

                icon: Icon(
                  obsecurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black54,
                ),
              ),
            ),
          ),

          Preset.smallSpace,

          // BUTTON LOGIN
          Button(
            width: double.infinity,
            title: 'Login',
            disable: false,

            onPressed: login,

            padding: const EdgeInsets.all(15),
          ),
        ],
      ),
    );
  }
}