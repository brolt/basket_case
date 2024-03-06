// add_basket.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'database_helper.dart';
import 'location_helper.dart';
import 'model/disc_golf_course.dart';

class AddBasket extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final DiscGolfCourse course;

  const AddBasket({
    super.key,
    required this.databaseHelper,
    required this.course,
  });

  @override
  AddBasketState createState() => AddBasketState();
}

class AddBasketState extends State<AddBasket> {
  int selectedHole = 1;
  Position currentPosition = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );

  @override
  void initState() {
    super.initState();
    // Initialize the database when the widget is created
    initializeDatabase();
  }

  Future<void> initializeDatabase() async {
    // After initializing the database, get the initial location
    await getLocation();
  }

  Future<void> getLocation() async {
    try {
      Position position = await LocationHelper.getCurrentLocation();

      setState(() {
        currentPosition = position;
      });
    } catch (e) {}
  }

  void saveBasket() async {
    // Ensure that the database is initialized
    if (!widget.databaseHelper.isInitialized()) {
      return;
    }

    if (currentPosition.latitude.isNegative) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Coordinates are strange...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Create a DiscGolfBasket object with the information
    DiscGolfBasket basket = DiscGolfBasket(
      courseId: widget.course.id,
      basketNumber: selectedHole,
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );

    // Save the course to the database using your DatabaseHelper
    // Assuming you have a databaseHelper instance available
    int basketId = await widget.databaseHelper.insertBasket(basket);

    if (basketId != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The baskets position was saved!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Lägg till korg på ${widget.course.name}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<int>(
              value: selectedHole,
              items: List.generate(18, (index) => index + 1)
                  .map((value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          'Hole $value',
                          style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.black,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedHole = value!;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Coordinates:',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Latitude:',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  currentPosition.latitude.toString(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 16.0),
                const Text(
                  'Longitude:',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  currentPosition.longitude.toString(),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                await getLocation();
              },
              child: const Text(
                'Get Current Position',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                saveBasket();
              },
              child: const Text(
                'Save Basket',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
