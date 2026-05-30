import 'package:flutter/material.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/models/user.dart';
import 'package:mobile/providers/user_provider.dart';
import 'package:mobile/services/user_service.dart';
import 'package:mobile/utils/config.dart';
import 'package:provider/provider.dart';

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
    if (!_formKey.currentState!.validate()) return;

    UserRequests userRequests = UserRequests(
      email: _emailController.text,
      password: _passController.text,
    );

    if (!mounted) return;

    // Panggil login melalui provider dengan loading state
    UserResponse? user = await context.read<UserProvider>().login(userRequests);

    if (user != null) {
      if (!mounted) return;

      // Simpan ke provider
      context.read<UserProvider>().setLoggedInUser(user);

      Navigator.pushReplacementNamed(context, 'home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email atau Password salah')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Stack(
          children: [
            Form(
              key: _formKey,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // EMAIL
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Colors.black54,
                    enabled: !userProvider.isLoginLoading,

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
                    enabled: !userProvider.isLoginLoading,

                    obscureText: obsecurePass,

                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),

                      hintText: 'Password',
                      labelText: 'Password',

                      alignLabelWithHint: true,

                      prefixIcon: const Icon(Icons.lock),

                      suffixIcon: IconButton(
                        onPressed: !userProvider.isLoginLoading
                            ? () {
                                setState(() {
                                  obsecurePass = !obsecurePass;
                                });
                              }
                            : null,

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
                    title: userProvider.isLoginLoading ? 'Loading...' : 'Login',
                    disable: userProvider.isLoginLoading,

                    onPressed: userProvider.isLoginLoading
                        ? () {}
                        : () {
                            login();
                          },

                    padding: const EdgeInsets.all(15),
                  ),
                ],
              ),
            ),
            // LOADING OVERLAY
            if (userProvider.isLoginLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
