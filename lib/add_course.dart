import 'package:flutter/material.dart';

import 'database_helper.dart';
import 'model/disc_golf_course.dart';

class AddCourse extends StatefulWidget {
  final DatabaseHelper databaseHelper;
  const AddCourse({super.key, required this.databaseHelper});

  @override
  AddCourseState createState() => AddCourseState();
}

class AddCourseState extends State<AddCourse> {
  List<Widget> basketWidgets = [];
  final TextEditingController courseNameController = TextEditingController();

  void saveCourse(String name) async {
    // Validate that a course name is provided
    if (name.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter a course name.'),
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

    // Create a DiscGolfCourse object with the entered information
    DiscGolfCourse course = DiscGolfCourse(
      name: name,
    );

    // Save the course to the database using your DatabaseHelper
    // Assuming you have a databaseHelper instance available
    int courseId = await widget.databaseHelper.insertCourse(course);

    if (courseId != -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The course was created!'),
        ),
      );
      courseNameController.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ERROR ERROR ERROR!'),
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
        title: const Text(
          'Add Disc Golf Course',
          style: TextStyle(
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
            TextField(
              controller: courseNameController,
              decoration: InputDecoration(
                labelText: 'Banans namn',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save), // Save icon
                  onPressed: () {
                    saveCourse(courseNameController.text);
                  },
                  color: Colors.deepOrange,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
