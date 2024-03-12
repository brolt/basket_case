import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model/disc_golf_course.dart';

class DatabaseHelper {
  late final Database database;

  Future<void> initializeDatabase() async {
    final path = await getDatabasesPath();
    final discGolfDbPath = join(path, 'disc_golf.db');

    database =
        await openDatabase(discGolfDbPath, version: 1, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE disc_golf_courses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');

      db.execute('''
        CREATE TABLE disc_golf_baskets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          courseId INTEGER,
          basketNumber INTEGER UNIQUE,
          latitude REAL,
          longitude REAL,
          FOREIGN KEY (courseId) REFERENCES disc_golf_courses (id)
        )
      ''');
    });
  }

  bool isInitialized() {
    return database.isOpen;
  }

  Future<int> insertCourse(DiscGolfCourse course) async {
    int courseId = await database.insert('disc_golf_courses', {
      'name': course.name,
    });

    return courseId;
  }

  Future<int> insertBasket(DiscGolfBasket basket) async {
    int basketId = await database.insert('disc_golf_baskets', {
      'courseId': basket.courseId,
      'basketNumber': basket.basketNumber,
      'latitude': basket.latitude,
      'longitude': basket.longitude,
    });

    return basketId;
  }

  Future<int> updateBasket(DiscGolfBasket basket) async {
    int basketId = await database.update(
        'disc_golf_baskets',
        {
          'courseId': basket.courseId,
          'basketNumber': basket.basketNumber,
          'latitude': basket.latitude,
          'longitude': basket.longitude,
        },
        where: 'basketId = ?');

    return basketId;
  }

  Future<List<DiscGolfCourse>> getCourses() async {
    final List<Map<String, dynamic>> courseMaps =
        await database.query('disc_golf_courses');
    List<DiscGolfCourse> courses = [];

    for (Map<String, dynamic> courseMap in courseMaps) {
      courses.add(DiscGolfCourse.fromMap({
        'id': courseMap['id'],
        'name': courseMap['name'],
      }));
    }

    return courses;
  }

  Future<List<DiscGolfBasket>> getBaskets(DiscGolfCourse course) async {
    final List<Map<String, dynamic>> basketMaps = await database.query(
        'disc_golf_baskets',
        where: 'courseId = ?',
        whereArgs: [course.id]);

    List<DiscGolfBasket> baskets = [];

    for (Map<String, dynamic> basketMap in basketMaps) {
      baskets.add(DiscGolfBasket.fromMap({
        'id': basketMap['id'],
        'courseId': basketMap['courseId'],
        'basketNumber': basketMap['basketNumber'],
        'latitude': basketMap['latitude'],
        'longitude': basketMap['longitude'],
      }));
    }

    return baskets;
  }
}
