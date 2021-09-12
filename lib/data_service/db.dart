import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:qr_scan/data_service/saved_qr_data.dart';

class QRDatabase {

  
  static final QRDatabase instance = QRDatabase._init();

  static Database? _database;

  QRDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('qr.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE $tableQR ( 
        ${QRFields.id} $idType, 
        ${QRFields.title} $textType,
        ${QRFields.link} $textType
      )
       ''');
  }

  Future<SavedQRData> create(SavedQRData qr) async {
    final db = await instance.database;
    final id = await db.insert(tableQR, qr.toJson());
    return qr.copy(id: id);
  }

  Future<SavedQRData> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableQR,
      columns: QRFields.values,
      where: '${QRFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SavedQRData.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<SavedQRData>> readAllNotes() async {
    final db = await instance.database;

    final orderBy = '${QRFields.title} ASC';
    final result = await db.query(tableQR, orderBy: orderBy);
    return result.map((json) => SavedQRData.fromJson(json)).toList();
  }

  Future<int> update(SavedQRData qr) async {
    final db = await instance.database;

    return db.update(
      tableQR,
      qr.toJson(),
      where: '${QRFields.id} = ?',
      whereArgs: [qr.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableQR,
      where: '${QRFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
