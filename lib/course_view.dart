// CourseView.dart

import 'dart:async';

import 'package:basket_case/model/disc_golf_course.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'add_basket.dart';
import 'database_helper.dart';
import 'location_helper.dart';

class CourseView extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  final DiscGolfCourse course;

  const CourseView(
      {required this.course, required this.databaseHelper, super.key});

  @override
  CourseViewState createState() => CourseViewState();
}

class CourseViewState extends State<CourseView> {
  List<DiscGolfBasket> closestBaskets = [];
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
      speedAccuracy: 0);

  @override
  void initState() {
    super.initState();
    getLocation();
    fetchClosestBaskets();
    startLocationReloadTimer();
  }

  void startLocationReloadTimer() {
    const Duration reloadInterval = Duration(seconds: 3);

    Timer.periodic(reloadInterval, (Timer timer) async {
      await getLocation();
      fetchClosestBaskets();
    });
  }

  Future<void> getLocation() async {
    try {
      Position position = await LocationHelper.getCurrentLocation();

      setState(() {
        currentPosition = position;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // Function to fetch the closest baskets from the database
  void fetchClosestBaskets() async {
    try {
      List<DiscGolfBasket> baskets =
          await widget.databaseHelper.getBaskets(widget.course);

      // Sort baskets by distance from the current position
      baskets.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          a.latitude,
          a.longitude,
        );

        double distanceB = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          b.latitude,
          b.longitude,
        );

        return distanceA.compareTo(distanceB);
      });

      // Take the five closest baskets
      closestBaskets = baskets.take(5).toList();

      setState(() {}); // Update the UI with the closest baskets
    } catch (e) {}
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
          widget.course.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Column(
              children: closestBaskets.map((basket) {
                double distance = Geolocator.distanceBetween(
                  currentPosition.latitude,
                  currentPosition.longitude,
                  basket.latitude,
                  basket.longitude,
                );
                return Text(
                  'Hole ${basket.basketNumber}: ${distance.round()} meters',
                  style: const TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),
            IconButton(
              iconSize: 100,
              icon: const Icon(Icons.update),
              color: Colors.green,
              onPressed: () {
                getLocation();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBasket(
                databaseHelper: widget.databaseHelper,
                course: widget.course,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
