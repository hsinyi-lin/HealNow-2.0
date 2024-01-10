import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_app/screen/home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  // final TextEditingController genderController = TextEditingController();
  String selectGender = 'M'; // gender

  String loginError = '';
  bool isRegisterMode = false;

  static const String baseUrl = 'https://healnow.azurewebsites.net/auth';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      setState(() {
        loginError = '';
      });

      var response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status code: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'] as String?;

        if (token != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);

          String? storedToken = prefs.getString('token');
          print('Stored token in SharedPreferences: $storedToken');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        } else {
          print('Login error: Token is null');
        }
      } else {
        setState(() {
          loginError = '登入失敗, 請確認帳號密碼';
        });
      }
    } catch (error) {
      print('Login error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('登入失敗, 請重新登入'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('token');
    return storedToken != null && storedToken.isNotEmpty;
  }

  Future<void> register(
      String email, String password, String username, String gender) async {
    try {
      if (gender == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('性別未被選取'),
              content: Text('請選擇性別'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'username': username,
          'gender': gender,
        }),
      );
      print('Register response status code: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['access_token'] as String?;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      } else if (response.statusCode == 400) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String errorMessage = responseData['msg'];

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('已被註冊的帳號'),
              content: Text(errorMessage),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Handle other registration failure cases
      }
    } catch (error) {
      print('Register error: $error');
    }
  }

  Future<void> sendVerificationCode(String email) async {
    try {
      final url = Uri.parse('$baseUrl/send_verification');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            String code = '';
            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: Text('請輸入驗證碼'),
                  contentPadding:
                      EdgeInsets.only(top: 10, bottom: 5, left: 20, right: 20),
                  content: TextField(
                    onChanged: (value) => setState(() => code = value),
                    decoration: InputDecoration(hintText: '驗證碼'),
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        verifyCode(email, code);
                        Navigator.of(context).pop();
                      },
                      child: Text('驗證碼'),
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        throw Exception(
            'Failed to send verification code. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending verification code: $error');
      // Add additional error handling as needed
    }
  }

  Future<void> verifyCode(String email, String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('$baseUrl/send_verification');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'email': email}),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        print('驗證成功');
        // 驗證碼驗證成功，彈出更改密碼的對話框
        showChangePasswordDialog(email, token);
      } else {
        throw Exception('驗證失敗');
      }
    } catch (error) {
      print('Error: $error');
      throw error;
    }
  }

// 新增方法：彈出更改密碼的對話框
  Future<void> showChangePasswordDialog(String email, String? token) async {
    try {
      await showDialog(
        context: _scaffoldKey.currentContext!,
        builder: (BuildContext context) {
          String new_password = '';

          return AlertDialog(
            title: Text('更改密碼'),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            content: Container(
              height: 80, // 調整高度
              child: Column(
                children: [
                  Text('輸入新密碼:'),
                  TextField(
                    onChanged: (value) => new_password = value,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '新密碼',
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // 更改密碼
                  await changePassword(email, new_password);
                  Navigator.of(context).pop(); // 關閉對話框
                },
                child: Text('更改密碼'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> changePassword(String email, String new_password) async {
    try {
      final url =
          Uri.parse('https://healnow.azurewebsites.net/auth/change_password');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      // 不再需要 email，因為已經在 showChangePasswordDialog 方法中傳遞
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'is_login': false,
          'email': email,
          'new_password': new_password,
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        await showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('更改密碼成功'),
              content: Text('請使用新密碼登入'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        await showDialog(
          context: _scaffoldKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('更改密碼失敗'),
              content: Text('請再試一次'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void toggleRegisterMode() {
    setState(() {
      isRegisterMode = !isRegisterMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/loginc.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: 20, bottom: 10, left: 20, right: 20),
                    width: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: Container(
                        color: Colors.white.withOpacity(0.5),
                        // 因圖示被壓縮改成 AspectRatio
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Image.asset(
                            'assets/images/login.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.deepPurple.shade100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintStyle: TextStyle(color: Colors.grey[400]!),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: '密碼',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.cyan.shade100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            obscureText: true,
                          ),
                          if (isRegisterMode) ...[
                            SizedBox(height: 10),
                            TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: '用戶名稱',
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.deepOrange.shade100),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // Gender
                            Align(
                              alignment: Alignment.centerLeft,
                              //性別選單
                              child: Container(
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                      color: Color.fromARGB(36, 225, 39, 101),
                                      width: 0.5),
                                ),
                                child: DropdownButton<String>(
                                  value: selectGender,
                                  items: ['M', 'F'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectGender = newValue;
                                      });
                                    }
                                  },
                                  dropdownColor: Colors.white,
                                  style: TextStyle(color: Colors.black),
                                  icon: Icon(Icons.arrow_drop_down,
                                      color: const Color.fromARGB(
                                          144, 233, 30, 98)),
                                  underline: Container(
                                    height: 0,
                                  ),
                                  elevation: 1,
                                  isExpanded: true,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (isRegisterMode) {
                                  register(
                                    emailController.text,
                                    passwordController.text,
                                    usernameController.text,
                                    selectGender,
                                  );
                                } else {
                                  login(
                                    context,
                                    emailController.text,
                                    passwordController.text,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                primary: Colors.pink.shade400,
                                fixedSize: Size(double.infinity, 50),
                              ),
                              child: Text(
                                isRegisterMode ? '註冊' : '登入',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: toggleRegisterMode,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Text(
                                isRegisterMode ? '已經有帳號 ? 登入' : '沒有帳號 ? 註冊',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: _scaffoldKey.currentContext!,
                                        builder: (BuildContext context) {
                                          String email = '';

                                          return StatefulBuilder(
                                            builder: (BuildContext context,
                                                StateSetter setState) {
                                              return AlertDialog(
                                                title: Text('忘記密碼'),
                                                content: Container(
                                                  height: 80, // 調整高度
                                                  child: Column(
                                                    children: [
                                                      Text('輸入Email'),
                                                      TextField(
                                                        onChanged: (value) =>
                                                            setState(() =>
                                                                email = value),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText: 'Email',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      sendVerificationCode(
                                                          email);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: Text(
                                                        '發送驗證碼'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      '忘記密碼',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            loginError,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
