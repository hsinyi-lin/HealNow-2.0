import 'package:flutter/material.dart';
import 'user_screen.dart';


class PersonalPage extends StatelessWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),  // 整體邊距
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,  // 列間距
            mainAxisSpacing: 10,  // 行間距
            childAspectRatio: 1.5, // 調整整體寬高比，使按鈕更緊湊
            children: <Widget>[
              _buildSquareButton(
                '收藏',
                Icons.star,
                () {
                  
                },
              ),
              _buildSquareButton(
                '心情',
                Icons.mood,
                () {

                },
              ),
              _buildSquareButton(
                '個人資料',
                Icons.person,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserScreen()),
                  );
                },
              ),
              _buildSquareButton(
                '登出',
                Icons.exit_to_app,
                () {
                  
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSquareButton(String title, IconData icon, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shadowColor: Colors.grey,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 24),
            Text(title, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
