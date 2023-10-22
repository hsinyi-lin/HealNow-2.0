import 'package:flutter/material.dart';
import 'detail.dart';


class Myhome extends StatefulWidget {
  const Myhome({Key? key}) : super(key: key);

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  int totalItems = 300;
  int itemsPerPage = 30;
  List<List<String>> data = [];

  @override
  void initState() {
    super.initState();
    fetchPageData(currentPage);
  }

  void fetchPageData(int page) {
    if (data.length <= page) {
      List<String> pageData = [];
      int startIndex = page * itemsPerPage + 1;
      int endIndex = (page + 1) * itemsPerPage;
      for (int i = startIndex; i <= endIndex; i++) {
        pageData.add('項目 $i');
      }

      setState(() {
        while (data.length <= page) {
          data.add([]);
        }
        data[page] = pageData;
      });
    }
  }

  void _navigateToDetailPage(String itemTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(title: itemTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: Builder(
      //     builder: (BuildContext innerContext) {
      //       return IconButton(
      //         icon: Icon(Icons.menu),
      //         onPressed: () {
      //           Scaffold.of(innerContext).openDrawer();
      //         },
      //       );
      //     },
      //   ),
      //   title: const Text('Example title'),
      //   actions: const [],
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 350,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[300],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '搜尋',
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: (totalItems / itemsPerPage).ceil(),
                onPageChanged: (int page) {
                  setState(() {
                    currentPage = page;
                    if (data.length <= page) {
                      fetchPageData(page);
                    }
                  });
                },
                itemBuilder: (BuildContext context, int page) {
                  if (data.isEmpty ||
                      data.length <= page ||
                      data[page] == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: data[page].length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(data[page][index]),
                        subtitle: const Text('2023-10-19'),
                        onTap: () {
                          _navigateToDetailPage(data[page][index]);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
                Text('頁數 ${currentPage + 1}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      // drawer: Drawer(
      //   child: ListView(
      //     children: [
      //       ListTile(
      //         title: Text('首頁'),
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         title: Text('闢謠專區'),
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         title: Text('身體安全的新聞'),
      //         onTap: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //       ListTile(
      //         title: Text('藥局地圖'),
      //         onTap: () {
      //           Navigator.pop(context);
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => MapPage()),
      //           );
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      
    );
  }
}
