import 'package:edubuddy/Attendance/attend.dart';
import 'package:edubuddy/cgpa/cgpa.dart';
import 'package:edubuddy/notes/screens/note_screen.dart' hide NavDrawer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edubuddy/toDo/M4copy.dart';

import 'widgets/NavBar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CollectionReference toDoColRef;
  late CollectionReference notesColRef;
  late CollectionReference attendanceColRef;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        toDoColRef = FirebaseFirestore.instance
            .collection('ToDoList')
            .doc(userEmail)
            .collection('ToDo');

        notesColRef = FirebaseFirestore.instance
            .collection('Notes')
            .doc(userEmail)
            .collection('Note');

        attendanceColRef = FirebaseFirestore.instance
            .collection('Attendance')
            .doc(userEmail)
            .collection('Attend');
      }
    }
  }

  Future<String?> getLatestToDoListItem() async {
    try {
      QuerySnapshot querySnapshot =
          await toDoColRef.orderBy('date', descending: false).limit(3).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['title'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving latest to-do list item: $e');
      return null;
    }
  }

  Future<String?> getLatestNote() async {
    try {
      QuerySnapshot querySnapshot = await notesColRef
          .orderBy('dateTime', descending: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['title'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error retrieving latest note: $e');
      return null;
    }
  }

  Future<int> getNotesCount() async {
    try {
      QuerySnapshot querySnapshot = await notesColRef.get();
      return querySnapshot.docs.length;
    } catch (e) {
      print('Error retrieving notes count: $e');
      return 0;
    }
  }

  Future<List<DocumentSnapshot>> getSubjectsWithLowAttendance() async {
    List<DocumentSnapshot> subjects = [];
    try {
      QuerySnapshot querySnapshot = await attendanceColRef.get();
      querySnapshot.docs.forEach((documentSnapshot) {
        double percentage =
            (documentSnapshot['attended'] / documentSnapshot['total']) * 100;
        int goal = documentSnapshot['goal'];
        if (percentage < goal) {
          subjects.add(documentSnapshot);
        }
      });
    } catch (e) {
      print('Error retrieving subjects with low attendance: $e');
    }
    return subjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(children: <Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const M4toDoList()),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'To-Do List',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<String?>(
                          future: getLatestToDoListItem(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasData) {
                              return Text(
                                'Latest Item: ${snapshot.data}',
                                style: const TextStyle(fontSize: 16),
                              );
                            } else {
                              return const Text(
                                'No items available',
                                style: TextStyle(fontSize: 16),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NoteScreen()),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Notes',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        FutureBuilder<String?>(
                          future: getLatestNote(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasData) {
                              return Column(
                                children: [
                                  Text(
                                    'Latest Note: ${snapshot.data}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  FutureBuilder<int>(
                                    future: getNotesCount(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator();
                                      } else {
                                        return Text(
                                          'Total Notes: ${snapshot.data}',
                                          style: const TextStyle(fontSize: 16),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return const Text(
                                'No notes available',
                                style: TextStyle(fontSize: 16),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Attendance()),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Subjects with Low Attendance',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          FutureBuilder<List<DocumentSnapshot>>(
                            future: getSubjectsWithLowAttendance(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasData &&
                                  snapshot.data!.isNotEmpty) {
                                return Column(
                                  children: snapshot.data!.map((document) {
                                    return ListTile(
                                      title: Text(document['name']),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Attended: ${document['attended']}',
                                          ),
                                          Text(
                                            'Total: ${document['total']}',
                                          ),
                                          Text(
                                            'Goal: ${document['goal']}%',
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                );
                              } else {
                                return const Text(
                                  'No subjects with low attendance',
                                  style: TextStyle(fontSize: 16),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const Cgpa()), // Navigate to CGPA page
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'SGPA',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Semester 4 SGPA: 4.5', // Example SGPA
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
