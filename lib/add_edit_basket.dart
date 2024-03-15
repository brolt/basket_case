import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'database_helper.dart';
import 'location_helper.dart';
import 'model/disc_golf_course.dart';

enum AddEditMode { add, edit }

class AddEditBasket extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final DiscGolfCourse course;
  final AddEditMode mode;
  final int? editBasketNumber;

  const AddEditBasket({
    super.key,
    required this.databaseHelper,
    required this.course,
    required this.mode,
    this.editBasketNumber,
  });

  @override
  AddEditBasketState createState() => AddEditBasketState();
}

class AddEditBasketState extends State<AddEditBasket> {
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
        basketMarker = Marker(
            point: latLng,
            child: const Icon(Icons.adjust, color: Colors.blueGrey));
        mapController.move(latLng, 19);
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String title = (widget.mode == AddEditMode.add)
        ? "Lägg till korg på ${widget.course.name}"
        : "Redigera korg på ${widget.course.name}";

    String saveButtonLabel =
        (widget.mode == AddEditMode.add) ? "Spara korg" : "Uppdatera korg";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors
                          .blueGrey, // Background color of the dropdown button
                      border: Border.all(color: Colors.black, width: 1),
                      // Border of the dropdown button
                      borderRadius: BorderRadius.circular(10),
                      // Border radius of the dropdown button
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        height: 60,
                        child: ListWheelScrollView(
                          physics: const FixedExtentScrollPhysics(),
                          itemExtent: 60,
                          children: List.generate(
                            18,
                            (index) => Center(
                              child: Text(
                                'Hål ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              selectedHole = index + 1;
                            });
                          },
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
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    height: 300,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: FlutterMap(
                        mapController: mapController,
                        options: const MapOptions(
                          initialCenter:
                              LatLng(59.293944788014024, 14.094192662444502),
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
                              TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                  onTap: () {}),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Add the Row widget to contain the buttons
                  Row(
                    children: [
                      // First Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await getLocation();
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 56),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueGrey[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          child: const Text(
                            'Förnya position',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                          width: 5.0), // Add some space between buttons

                      // Second Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (widget.mode == AddEditMode.add) {
                              saveBasket();
                            } else {
                              updateBasket();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 56),
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                          child: Text(
                            saveButtonLabel,
                            style: const TextStyle(
                              fontSize: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void saveBasket() async {
    if (!widget.databaseHelper.isInitialized()) {
      return;
    }

    DiscGolfBasket basket = DiscGolfBasket(
      courseId: widget.course.id,
      basketNumber: selectedHole,
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );

    int? basketId = await widget.databaseHelper.insertBasket(basket);

    if (basketId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Korgens position har sparats!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Korgen på detta hål har redan en position sparad. Gå tillbaks till banans sida och välj hålet för att redigera positionen!'),
        ),
      );
    }
  }

  updateBasket() async {
    if (!widget.databaseHelper.isInitialized()) {
      return;
    }

    DiscGolfBasket basket = DiscGolfBasket(
      courseId: widget.course.id,
      basketNumber: selectedHole,
      latitude: currentPosition.latitude,
      longitude: currentPosition.longitude,
    );

    int basketId = await widget.databaseHelper.updateBasket(basket);

    if (basketId != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Korgens position har uppdaterats!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Något gick fel när korgen skulle uppdateras'),
        ),
      );
    }
  }
}
