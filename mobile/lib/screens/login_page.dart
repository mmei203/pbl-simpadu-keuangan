import 'package:flutter/material.dart';
import 'package:keuangan_simpadu/screens/colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // background image
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/image.png'),
            fit: BoxFit.cover
          ),
        ),

        // box login
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20))
                ),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 60),
                child: Column(
                  spacing: 30,
                  children: [
                    // welcome text
                    Column(
                      spacing: 12,
                      children: [
                        Text(
                          'Selamat Datang',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        Text('SILAHKAN LOGIN'),
                      ],
                    ),
                    // login, Password, button
                    SizedBox(
                      width: 315,
                      child: Column(
                        spacing: 20,
                        children: [
                          // login input
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 15,
                            children: [
                              Text('Username'),
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hint: Text(
                                    'Masukan username/e-mail',
                                    style: TextStyle(
                                      color: Colors.black.withAlpha(125)
                                    ),
                                  )
                                ),
                              ),
                              Text('Password'),
                              TextField(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hint: Text(
                                    'Masukan password',
                                    style: TextStyle(
                                      color: Colors.black.withAlpha(125)
                                    ),
                                  )
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: (){}, 
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textOnPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(15)
                              ),
                              minimumSize: Size(200, 60)
                            ),
                            child: Text('Login'))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}