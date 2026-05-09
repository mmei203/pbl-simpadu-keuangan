import 'package:flutter/material.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/utils/config.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}


class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Colors.black54,
            decoration: InputDecoration(
              hintText: 'Gmail',
              labelText: 'Username',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email),
              prefixIconColor: Colors.black54,
            ),
          ),
          Preset.smallSpace,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Colors.black54,
            obscureText: obsecurePass,
            decoration: InputDecoration(
              hintText: 'Password',
              labelText: 'Password',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.lock),
              prefixIconColor: Colors.black54,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obsecurePass = !obsecurePass;
                  });
                },
                icon: obsecurePass
                    ? 
                    Icon(
                      Icons.visibility_off_outlined, 
                      color: Colors.black54
                    )
                    : Icon(
                        Icons.visibility_outlined,
                        color: Colors.black54,
                      ),
              ),
            ),
          ),
          Preset.smallSpace,
          Button(
            width: double.infinity, 
            title: 'Login', 
            disable: false, 
            onPressed: (){}, 
            padding: EdgeInsets.all(15)
          )
        ],
      ),
    );
  }
}