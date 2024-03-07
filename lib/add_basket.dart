// add_basket.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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
  final mapController = MapController();
  Marker basketMarker =
      const Marker(point: LatLng(0, 0), child: Icon(Icons.flag));
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
        LatLng latLng =
            LatLng(currentPosition.latitude, currentPosition.longitude);
        basketMarker = Marker(point: latLng, child: const Icon(Icons.flag));
        mapController.move(latLng, 19);
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
            DecoratedBox(
              decoration: BoxDecoration(
                color:
                    Colors.blueGrey, // Background color of the dropdown button
                border: Border.all(
                    color: Colors.black,
                    width: 1), // Border of the dropdown button
                borderRadius: BorderRadius.circular(
                    10), // Border radius of the dropdown button
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<int>(
                  value: selectedHole,
                  items: List.generate(18, (index) => index + 1)
                      .map((value) => DropdownMenuItem<int>(
                            value: value,
                            child: Text('Hål $value'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedHole = value!;
                    });
                  },
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  underline: Container(),
                  dropdownColor: Colors.blueGrey, // Dropdown background color
                  style: const TextStyle(
                    color: Colors.white, // Font color
                    fontSize: 16, // Font size on dropdown button
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Koordinater:',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Lattitud:',
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
                  'Longitud:',
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
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    side: const BorderSide(color: Colors.black), // Border color
                  )),
              child: const Text(
                'Hämta ny position',
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
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                    side: const BorderSide(color: Colors.black), // Border color
                  )),
              child: const Text(
                'Spara korg',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: 300,
              child: FlutterMap(
                mapController: mapController,
                options: const MapOptions(
                  initialCenter: LatLng(59.293944788014024, 14.094192662444502),
                  initialZoom: 14,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      basketMarker,
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('OpenStreetMap contributors',
                          onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
