import 'package:postgres/postgres.dart';

PostgreSQLConnection createDatabaseConnection() {
  return PostgreSQLConnection(
    'satao.db.elephantsql.com',
    5432,
    'ndobrxgj',
    username: 'ndobrxgj',
    password: 'E76tNK7sibvKe-Oo7mr6daLGRbHA6MOK',
  );
}

class DatabaseHelper {
  final PostgreSQLConnection _connection;

  DatabaseHelper(this._connection);

  Future<void> openConnection() async {
    await _connection.open();
  }

  Future<void> closeConnection() async {
    await _connection.close();
  }

  // List<Map<String, dynamic>> sampleData = [
  //   {
  //     'id': 1,
  //     'name': 'John',
  //     'age': 30,
  //     'city': 'New York',
  //   },
  //   {
  //     'id': 2,
  //     'name': 'Alice',
  //     'age': 25,
  //     'city': 'Los Angeles',
  //   }
  // ];
  Future<List<Map<String, dynamic>>> fetchMedData() async {
    final result = await _connection.query('SELECT * FROM med limit 60');

    for (final row in result) {
      final id = row[0];
      final name = row[1];
      print('ID: $id, Name: $name');
    }

    final dataList = result.map((row) => row.toColumnMap());
    return dataList.toList();
  }

  // Add other database operation methods
}
