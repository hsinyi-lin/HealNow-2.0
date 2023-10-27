import 'package:flutter/material.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class MoodPage extends StatefulWidget {
  const MoodPage({super.key});

  @override
  State<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends State<MoodPage> {
  List<String> moodTexts = [];
  TextEditingController moodTextController = TextEditingController();
  FocusNode moodTextFocus = FocusNode();
  String currentDate = '';
  bool hasMoodEntered = false;

  @override
  void initState() {
    super.initState();
    moodTextController.text = '';
  }

  void _showMoodInput() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: FractionallySizedBox(
            widthFactor: 0.9,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('今日心情'),
                  if (currentDate.isNotEmpty) Text(currentDate),
                  TextField(
                    controller: moodTextController,
                    focusNode: moodTextFocus,
                    onChanged: (text) {
                      setState(() {
                        // 不再更新moodText
                      });
                    },
                    decoration: InputDecoration(
                      hintText: hasMoodEntered ? '修改今日心情' : '輸入今日心情',
                      hintStyle: TextStyle(
                          color: moodTextFocus.hasFocus
                              ? Colors.black
                              : Colors.grey),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentDate =
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                        hasMoodEntered = true;
                      });
                      Navigator.of(context).pop();
                      if (hasMoodEntered) {
                        int index = moodTexts
                            .indexWhere((text) => text.startsWith(currentDate));
                        if (index != -1) {
                          moodTexts[index] =
                              '$currentDate\n${moodTextController.text}';
                        } else {
                          moodTexts
                              .add('$currentDate\n${moodTextController.text}');
                        }
                      }
                      moodTextController.text = '';
                    },
                    child: const Text('確認'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    moodTextController.dispose();
    moodTextFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("記錄心情"),
      ),
      drawer: const AppDrawer(),
      body: ListView(
        children: moodTexts.map((text) {
          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Text(text),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 2, horizontal: 20), // 设置分隔线的padding
                  child: const Divider(
                    color: Color.fromARGB(255, 204, 203, 203), // 设置分隔线颜色
                    thickness: 2, // 设置分隔线粗细
                  ),
                ),
                const ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ChatGPT回覆',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5), // 在两个文本之间增加5px的间距
                      Text('自动回复：这是自动回复的内容'),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          moodTextFocus.requestFocus();
          _showMoodInput();
        },
        tooltip: 'Increment',
        child: Icon(hasMoodEntered ? Icons.edit : Icons.add),
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
