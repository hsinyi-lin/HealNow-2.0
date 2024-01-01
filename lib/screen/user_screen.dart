import 'dart:convert';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  String _imageUrl = '';
  String photo = '';
  Map<String, dynamic> userData = {};

  late String token;

  TextStyle myTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: Colors.blue[900],
  );

  TextStyle secondTextStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: const Color.fromARGB(255, 124, 124, 124),
  );

  @override
  void initState() {
    super.initState();
    // Load user image URL and data from SharedPreferences
    loadToken().then((loadedToken) {
      token = loadedToken;

      setState(() {
        loadUserData();
        loadUserImageUrl();
      });
    });
  }

  Future<void> loadUserData() async {
    try {
      final response = await http.get(
        Uri.parse('https://healnow.azurewebsites.net/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Parse the response JSON and update the userData
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          userData = responseData['data'];
        });
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  Future<void> loadUserImageUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String imageUrl = prefs.getString('user_image_url') ?? '';
    print('Loaded user image URL: $imageUrl');
    setState(() {
      _imageUrl = imageUrl;
      photo = imageUrl;
    });
  }

  Future<void> saveUserImageUrl(String imageUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_image_url', imageUrl);
  }

  void showUpdateProfileDialog() {
    TextEditingController usernameController = TextEditingController();
    TextEditingController genderController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Profile'),
          content: Container(
            height: 200, // Set the desired height
            child: Column(
              children: [
                TextField(
                  controller: usernameController,
                  onChanged: (value) {
                    // Handle the username input
                  },
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: genderController,
                  onChanged: (value) {
                    // Handle the gender input
                  },
                  decoration: InputDecoration(labelText: 'Gender'),
                ),
                SizedBox(height: 16.0), // Add some spacing
                ElevatedButton(
                  onPressed: () async {
                    // Pick image and convert to base64
                    String base64Image = await _pickImage();
                    // Save base64 image to SharedPreferences
                    saveUserImageUrl(base64Image);
                  },
                  child: Text('Choose Photo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Get the updated username and gender from the text fields
                final updatedUsername = usernameController.text;
                final updatedGender = genderController.text;

                // Call the updateUserProfile method with the updated values
                updateUserProfile(
                  username: updatedUsername,
                  gender: updatedGender,
                  photo: _imageUrl, // Use the stored image URL
                );

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<String> _pickImage() async {
    print('Picking an image...');
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // 選圖
        List<int> imageBytes = await pickedFile.readAsBytes();

        // 轉成base64
        String base64Image = base64Encode(imageBytes);

        // 更新圖片 URL 和 UI
        setState(() {
          _imageUrl = base64Image;
          photo = base64Image;
        });

        print('Image picked and converted to base64: $base64Image');
        print('Server URL for the image: $photo');

        // Save base64 image to SharedPreferences
        saveUserImageUrl(base64Image);
        return base64Image;
      } else {
        // 取消選擇，保留原始 _imageUrl
        print('No image selected.');
        return _imageUrl;
        // return 'assets/images/login.png';
      }
    } catch (error) {
      print('Error picking image: $error');
      // 發生錯誤，保留原始 _imageUrl
      return _imageUrl;
    }
  }

  Future<void> updateUserProfile({
    required String username,
    required String gender,
    required String photo,
  }) async {
    // Make API call to update user profile
    // Use the 'photo' parameter to send the base64 image to the server
    // Update the user data if the API call is successful
    try {
      print('Updating user profile...');
      print('Username: $username, Gender: $gender, Photo: $photo');

      final response = await http.patch(
        Uri.parse('https://healnow.azurewebsites.net/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'gender': gender,
          'photo': photo,
          // 'photo': _imageUrl,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Update user data after successful API call
        loadUserData();
        // Update image URL in SharedPreferences
        saveUserImageUrl(_imageUrl); //使用 _imageUrl 來更新頭像
        // saveUserImageUrl(photo); // 使用 photo 參數來更新頭像
        setState(() {
          _imageUrl = photo; // 確保更新 _imageUrl
          this.photo = photo;
        });
        // saveUserImageUrl(_imageUrl);
        print('User profile updated successfully.');
      } else {
        print(
            'Failed to update user profile. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error updating user profile: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(174, 158, 158, 158),
        centerTitle: true,
        title: Text(
          'Hello, ${userData['username']}',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loginc.jpg'), // 背景圖片
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // 透明度
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color.fromARGB(136, 255, 255, 255),
                    width: 6.0,
                  ),
                ),
                child: Container(
                  width: 220.0,
                  height: 220.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 8.0, // 調整外圈的寬度
                    ),
                  ),
                  child: ClipOval(
                    child: photo.isNotEmpty
                        ? Image.memory(
                            base64Decode(_imageUrl),
                            fit: BoxFit.cover,
                            width: 200.0,
                            height: 200.0,
                          )
                        : Image.asset(
                            'assets/images/login.png',
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: showUpdateProfileDialog,
              //   child: Text('Update Profile'),
              // ),
              SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 20, 8, 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(214, 255, 255, 255),
                    border: Border.all(
                      color: Color.fromARGB(77, 194, 194, 194),
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 16.0),
                          Text('Username: ${userData['username']}',
                              style: myTextStyle),
                          SizedBox(height: 8.0),
                          Text('Email: ${userData['email']}',
                              style: myTextStyle),
                          SizedBox(height: 8.0),
                          Text('Gender: ${userData['gender']}',
                              style: myTextStyle),
                          SizedBox(height: 80.0),
                          Text('Created Time: ${userData['created_time']}',
                              style: secondTextStyle),
                          SizedBox(height: 8.0),
                          Text('Updated Time: ${userData['updated_time']}',
                              style: secondTextStyle),
                          SizedBox(height: 30.0),
                          ElevatedButton(
                            onPressed: showUpdateProfileDialog,
                            child: Text('Update Profile'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
