import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_screen.dart';
import 'login_screen.dart';



class Login extends StatelessWidget {
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    return storedToken != null && storedToken.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            if (snapshot.data == true) {
              // Retrieve the stored token from SharedPreferences
              Future<String?> getToken() async {
                return (await SharedPreferences.getInstance()).getString('token');
              }

              return FutureBuilder(
                future: getToken(),
                builder: (context, tokenSnapshot) {
                  if (tokenSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    return UserScreen(username: '', token: tokenSnapshot.data ?? '');
                  }
                },
              );
            } else {
              return LoginScreen();
            }
          }
        },
      ),
    );
  }
}
