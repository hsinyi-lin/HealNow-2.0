import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/home.dart';
import 'screen/login_screen.dart';


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

// class _MyAppHomeState extends State<MyAppHome> {
//   String _appBarTitle = 'HealNow';
//   final _currentBody = Login();
//   bool isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset(
//           'assets/images/healnow.png',
//           height: AppBar().preferredSize.height * 0.8,
//           fit: BoxFit.contain,
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: IconThemeData(color: Colors.grey),
//         elevation: 0,
//       ),
//       drawer: Drawer(
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   ListTile(
//                     leading: const Icon(Icons.group),
//                     title: const Text('社群討論'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       setState(() {
//                         _appBarTitle = '社群討論';
//                       });
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.hearing_outlined),
//                     title: const Text('心情紀錄'),
//                     onTap: () {
//                       Navigator.pop(context);
//                       setState(() {
//                         _appBarTitle = '心情紀錄';
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Divider(), // Divider
//             Column(
//               children: [
//                 ListTile(
//                   leading: const Icon(Icons.login),
//                   title: const Text('登入'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() {
//                       _appBarTitle = '登入';
//                       // _currentBody = LoginPage();
//                     });
//                   },
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.person_add),
//                   title: const Text('註冊'),
//                   onTap: () {
//                     Navigator.pop(context);
//                     setState(() {
//                       _appBarTitle = '註冊';
//                       // _currentBody = RegisterPage();
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: _currentBody,
//     );
//   }
// }
