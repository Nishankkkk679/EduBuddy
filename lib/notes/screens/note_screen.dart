import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubuddy/Attendance/screen.dart';
import 'package:edubuddy/auth/screens/signin_screen.dart';
import 'package:edubuddy/cgpa/cgpa.dart';
import 'package:edubuddy/toDo/M4copy.dart';
import 'package:flutter/material.dart';
import 'package:edubuddy/notes/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edubuddy/home_screen.dart';
import '../../Document/screen.dart';

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  bool sorted = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController dateTimeController = TextEditingController();

  late CollectionReference colRef; // Declare colRef here

  AsyncSnapshot<QuerySnapshot>? streamSnapshot;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        colRef = FirebaseFirestore.instance
            .collection('Notes')
            .doc(userEmail)
            .collection('Note');
      }
    }
  }

  getRandomColor() {
    Random random = Random();
    return backgroundColors[random.nextInt(backgroundColors.length)];
  }

  /* void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }*/

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    print("Update");

    if (documentSnapshot != null) {
      setState(() {
        titleController.text = documentSnapshot['title'];
        contentController.text = documentSnapshot['content']; // Fixed here
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Note"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter your title here",
                  ),
                ),
                TextField(
                  controller: contentController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something here',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                final String content = contentController.text;
                final Timestamp dateTime = Timestamp.now();
                if (title.isNotEmpty) {
                  await colRef.doc(documentSnapshot?.id).update({
                    "title": title,
                    "content": content,
                    "dateTime": dateTime,
                  });
                  setState(() {
                    titleController.text = '';
                    contentController.text = '';
                    dateTimeController.text = '';
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            )
          ],
        );
      },
    );
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create Note"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Enter your title here",
                  ),
                ),
                TextField(
                  controller: contentController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something here',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                final String content = contentController.text;
                final Timestamp dateTime = Timestamp.now();
                if (title.isNotEmpty) {
                  await colRef.add({
                    "title": title,
                    "content": content,
                    "dateTime": dateTime,
                  });

                  titleController.clear();
                  contentController.clear();

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _delete(String productId) async {
    await colRef.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  Future<void> _sort() async {
    QuerySnapshot querySnapshot =
        await colRef.orderBy('dateTime', descending: true).get();
    setState(() {
      // Set the state with sorted data
      streamSnapshot = querySnapshot as AsyncSnapshot<QuerySnapshot<Object?>>?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: const Center(child: Text('Notes')),
        ),
        body: StreamBuilder(
          stream: colRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              // Assign the snapshot data to streamSnapshot
              streamSnapshot = snapshot;
              return ListView.builder(
                itemCount: streamSnapshot!.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot!.data!.docs[index];

                  return GestureDetector(
                    onTap: () => _update(documentSnapshot),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      color: getRandomColor(),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ListTile(
                          title: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: (documentSnapshot['title']),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  height: 1.5),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              documentSnapshot['dateTime'].toDate().toString(),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade800),
                            ),
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _update(documentSnapshot)),
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
// Add new product
        floatingActionButton: FloatingActionButton(
          onPressed: () => _create(),
          child: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat);
  }
}

class NavDrawer extends StatefulWidget {
  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String _name = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<void> _getUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload(); // Refresh user data to get latest displayName
      user = FirebaseAuth.instance.currentUser;
      setState(() {
        _name = user?.displayName ?? '';
        _email = user?.email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(133, 10, 108, 13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _name.isEmpty ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text(_name.isEmpty ? '' : _name),
                ),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: _email.isEmpty ? 16 : 20,
                  ),
                  child: Text(_email.isEmpty ? '' : _email),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
              // Handle Attendance onTap
            },
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Attendance'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkInProgressPage()),
              );
              // Handle Attendance onTap
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('CGPA'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cgpa()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('To-Do List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const M4toDoList()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('Notes'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NoteScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note_add),
            title: const Text('Document'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkInPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('SignOut'),
            onTap: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                setState(() {
                  _name = '';
                  _email = '';
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
