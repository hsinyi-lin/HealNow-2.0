import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class SQLiteDatabaseHelper {
  // 第一個internal用於內部初始化，確保只創建一個類別實例
  static final SQLiteDatabaseHelper _instance = SQLiteDatabaseHelper.internal();

  // 定義一個factory 函式，以返回類別的單一實例
  factory SQLiteDatabaseHelper() => _instance;

  // 私有的靜態資料庫實體
  static Database? _db;

  // 用於訪問資料庫
  Future<Database> get db async {
    if (_db != null) {
      return _db!; // ! 用於確保不是null
    }
    _db = await initDb();
    return _db!;
  }

  // 此internal是為了外部使用，當外部使用SQLiteDatabaseHelper()，實際上是在調用factory函式
  SQLiteDatabaseHelper.internal();

  // 資料庫初始化
  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'heal_now.db');

    // await deleteDatabase(path);

    // 開啟連線
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  // 關閉連線
  Future closeDb() async {
    var dbClient = await db;
    dbClient.close();
  }

  // 建立資料表
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mood (
        id INTEGER PRIMARY KEY,
        content TEXT,
        ai_reply TEXT,
        created_at DATETIME
      )
    ''');
  }

  // 新增資料
  Future<int> insertData(Map<String, dynamic> data) async {
    var dbClient = await db;
    
    final now = DateTime.now();
    final eightHoursLater = now.add(const Duration(hours: 8));
    print(eightHoursLater);

    data['created_at'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(eightHoursLater);

    return await dbClient.insert('mood', data);
  }

  // 取得所有資料
  Future<List<Map<String, dynamic>>> getAllData() async {
    var dbClient = await db;
    return await dbClient.query('mood', orderBy: 'id DESC');
  }
}
