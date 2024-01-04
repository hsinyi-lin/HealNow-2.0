import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/home.dart';
import 'screen/login.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyAppHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyAppHome extends StatefulWidget {
  const MyAppHome({Key? key}) : super(key: key);

  @override
  State<MyAppHome> createState() => _MyAppHomeState();
}

class _MyAppHomeState extends State<MyAppHome> {
  late bool isLoggedIn;

  @override
  void initState() {
    super.initState();
    // 在這裡進行 isLoggedIn 的初始化
    isLoggedIn = false; // 或者根據你的邏輯賦予初值
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    setState(() {
      isLoggedIn = storedToken != null && storedToken.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? const HomePage() : LoginScreen();
  }
}