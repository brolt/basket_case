class DiscGolfCourse {
  int? id;
  String name;

  DiscGolfCourse({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory DiscGolfCourse.fromMap(Map<String, dynamic> map) {
    return DiscGolfCourse(
      id: map['id'] as int?,
      name: map['name'] as String,
    );
  }
}

class DiscGolfBasket {
  int? id; // Unique identifier for the basket
  int? courseId;
  int basketNumber;
  double latitude;
  double longitude;

  DiscGolfBasket({
    this.id,
    this.courseId,
    required this.basketNumber,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'basketNumber': basketNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DiscGolfBasket.fromMap(Map<String, dynamic> map) {
    return DiscGolfBasket(
      id: map['id'] as int?,
      courseId: map['courseId'] as int?,
      basketNumber: map['basketNumber'] as int,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
    );
  }
}
