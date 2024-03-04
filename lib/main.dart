import 'package:flutter/material.dart';

import 'add_course.dart';
import 'course_view.dart';
import 'database_helper.dart';
import 'model/disc_golf_course.dart';
import 'theme_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper databaseHelper = DatabaseHelper();
  await databaseHelper.initializeDatabase();

  runApp(MyApp(databaseHelper: databaseHelper));
}

class MyApp extends StatelessWidget {
  final DatabaseHelper databaseHelper;

  const MyApp({Key? key, required this.databaseHelper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kvar Till Korg',
      theme: lightTheme,
      home: DiscGolfHomePage(databaseHelper: databaseHelper),
    );
  }
}

class DiscGolfHomePage extends StatefulWidget {
  final DatabaseHelper databaseHelper;

  const DiscGolfHomePage({Key? key, required this.databaseHelper})
      : super(key: key);

  @override
  DiscGolfHomePageState createState() => DiscGolfHomePageState();
}

class DiscGolfHomePageState extends State<DiscGolfHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        title: const Text(
          'Kvar Till Korg',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchController,
              cursorColor: Colors.deepOrange,
              decoration: InputDecoration(
                labelText: 'Sök efter bana',
                hintStyle: const TextStyle(color: Colors.deepOrange),
                labelStyle: const TextStyle(color: Colors.deepOrange),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchCourses();
                  },
                  color: Colors.deepOrange,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepOrange.shade900),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: FutureBuilder<List<DiscGolfCourse>>(
                future: widget.databaseHelper.getCourses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No courses found.');
                  } else {
                    List<DiscGolfCourse> courses = snapshot.data!;
                    return ListView.builder(
                      itemCount: courses.length,
                      itemBuilder: (context, index) {
                        DiscGolfCourse course = courses[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(10)),
                            color: Colors.blueGrey,
                            border: Border.all(width: 1),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Text((index + 1).toString(),
                                  style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.bold)),
                            ),
                            title: GestureDetector(
                              onTap: () {
                                navigateToCourseView(context, course);
                              },
                              child: Text(
                                course.name,
                                style: const TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: Colors.blueGrey,
        // foregroundColor: Colors.white,
        onPressed: addNewCourse,
        tooltip: 'Lägg till bana',
        shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Colors.black),
            borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void navigateToCourseView(BuildContext context, DiscGolfCourse course) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CourseView(databaseHelper: widget.databaseHelper, course: course),
      ),
    );
  }

  void searchCourses() {
    // Implement the search logic based on the entered text (_searchController.text)
  }

  void addNewCourse() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddCourse(databaseHelper: widget.databaseHelper),
      ),
    );
  }
}
