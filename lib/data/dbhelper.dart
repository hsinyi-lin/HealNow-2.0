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
    final result = await _connection.query('SELECT * FROM med ');

    // for (final row in result) {
    //   final id = row[0];
    //   final name = row[1];
    //   print('ID: $id, Name: $name');
    // }

    final dataList = result.map((row) => row.toColumnMap());
    return dataList.toList();
  }

  Future<List<Map<String, dynamic>>> fetchMedDataByTitle(String title, int id) async {
    final result = await _connection.query(
      'SELECT * FROM med WHERE (med_tw_name = @title OR med_en_name = @title) AND id = @id',
      substitutionValues: {'title': title, 'id': id},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

Future<List<Map<String, dynamic>>> fetchNewsData() async {
    final result = await _connection.query('SELECT * FROM news ');
    final dataList = result.map((row) => row.toColumnMap());

    return dataList.toList();
  }

  Future<List<Map<String, dynamic>>> fetchNewsDataByTitle(String title, int id) async {
  final result = await _connection.query(
    'SELECT * FROM news WHERE title = @title AND id = @id',
    substitutionValues: {'title': title, 'id': id},
  );

  return result.map((row) => row.toColumnMap()).toList();
}

Future<List<Map<String, dynamic>>> fetchRumorData() async {
    final result = await _connection.query('SELECT * FROM clarification ');
    final dataList = result.map((row) => row.toColumnMap());

    return dataList.toList();
  }

Future<List<Map<String, dynamic>>> fetchRumorDataByTitle(String title, int id) async {
  final result = await _connection.query(
    'SELECT * FROM clarification WHERE title = @title AND id = @id',
    substitutionValues: {'title': title, 'id': id},
  );

  return result.map((row) => row.toColumnMap()).toList();
}

  // Add other database operation methods
  Future<List<Map<String, dynamic>>> fetchPharmacyData() async {
    final result = await _connection.query('SELECT * FROM pharmacy');
    final dataList = result.map((row) => row.toColumnMap());

    return dataList.toList();
  }
}
