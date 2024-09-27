import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/NavBar.dart';

class Cgpa extends StatefulWidget {
  const Cgpa({Key? key}) : super(key: key);

  @override
  _CgpaState createState() => _CgpaState();
}

class _CgpaState extends State<Cgpa> {
  late CollectionReference<Map<String, dynamic>> semRef;
  late TextEditingController _nameController;
  late TextEditingController _marksController;
  String? _selectedSemester;
  double sgpa = 0.0; // Variable to hold SGPA value
  double cgpa = 0.0; // Variable to hold CGPA value
  List<String> semesters = [
    'Semester 1',
    'Semester 2',
    'Semester 3',
    'Semester 4',
    'Semester 5',
    'Semester 6'
  ];
  AsyncSnapshot<QuerySnapshot>? streamSnapshot;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        _selectedSemester = 'Semester 1';
        _initializeSemRef(_selectedSemester!);
        _nameController = TextEditingController();
        _marksController = TextEditingController();
        _calculateSGPA();
        //calculateCGPA();
      }
    }
  }

  void _initializeSemRef(String semester) {
    setState(() {
      semRef = FirebaseFirestore.instance
          .collection('Cgpa')
          .doc(FirebaseAuth.instance.currentUser!.email)
          .collection('Semesters')
          .doc(semester)
          .collection('Subjects');
    });
  }

  void _updateSemRef(String semester) {
    setState(() {
      _selectedSemester = semester;
    });
    _initializeSemRef(semester);
    _calculateSGPA();
  }

  Future<void> _addSubject() async {
    if (_selectedSemester != null && _selectedSemester!.isNotEmpty) {
      semRef.doc(_selectedSemester).collection('Subjects');
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Add Subject"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    label: Text("Subject Name"),
                    hintText: "Enter subject name here",
                  ),
                ),
                TextFormField(
                  controller: _marksController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    label: Text("Marks"),
                    hintText: 'Enter subject marks here',
                  ),
                ),
              ],
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
                  final String name = _nameController.text;
                  final String marks = _marksController.text;
                  if (name.isNotEmpty) {
                    await semRef.add({
                      "name": name,
                      "marks": marks,
                    });

                    _nameController.clear();
                    _marksController.clear();

                    Navigator.of(context).pop();
                    _calculateSGPA(); // Recalculate SGPA after adding subject
                  }
                },
                child: const Text('ADD'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select a semester.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    print("Update");
    if (_selectedSemester != null && _selectedSemester!.isNotEmpty) {
      semRef.doc(_selectedSemester).collection('Subjects');
      if (documentSnapshot != null) {
        setState(() {
          _nameController.text = documentSnapshot['name'];
          _marksController.text = documentSnapshot['marks'];
        });
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("UPDATE MARKS"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    label: Text("Subject Name"),
                    hintText: "Enter subject name here",
                  ),
                ),
                TextFormField(
                  controller: _marksController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    label: Text("Marks"),
                    hintText: 'Enter subject marks here',
                  ),
                ),
              ],
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
                  final String name = _nameController.text;
                  final String marks = _marksController.text;
                  if (name.isNotEmpty) {
                    await semRef.doc(documentSnapshot?.id).update({
                      "name": name,
                      "marks": marks,
                    });

                    _nameController.clear();
                    _marksController.clear();

                    Navigator.of(context).pop();
                    _calculateSGPA(); // Recalculate SGPA after updating subject
                  }
                },
                child: const Text('UPDATE'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select a semester.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _delete(String productId) async {
    if (_selectedSemester != null && _selectedSemester!.isNotEmpty) {
      semRef.doc(_selectedSemester).collection('Subjects');
      await semRef.doc(productId).delete();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('You have successfully deleted a product')));
      _calculateSGPA(); // Recalculate SGPA after deleting subject
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select a semester.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  double calculateSGPA(List<DocumentSnapshot> subjects) {
    if (subjects.isEmpty) {
      return 0.0;
    } else {
      double totalCredits = 0;
      double totalGradePoints = 0;

      for (var subject in subjects) {
        int marks = int.parse(subject['marks']);
        double credit = 3.0; // Update credit to 3.0 for each subject
        double gradePoint = calculateGradePoint(marks);
        totalCredits += credit;
        totalGradePoints += credit * gradePoint;
      }

      return totalGradePoints / totalCredits;
    }
  }

  double calculateGradePoint(int marks) {
    if (marks >= 80) {
      return 10.0;
    } else if (marks >= 70) {
      return 9.0;
    } else if (marks >= 60) {
      return 8.0;
    } else if (marks >= 55) {
      return 7.0;
    } else if (marks >= 50) {
      return 6.0;
    } else if (marks >= 45) {
      return 5.0;
    } else if (marks >= 40) {
      return 4.0;
    } else {
      return 0.0;
    }
  }

  void _calculateSGPA() {
    semRef.snapshots().listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        // Filter the documents for the selected semester
        List<DocumentSnapshot> semesterSubjects = snapshot.docs
            .where(
                (doc) => doc.reference.parent.parent!.id == _selectedSemester)
            .toList();
        double newSGPA = calculateSGPA(semesterSubjects);
        setState(() {
          sgpa = newSGPA;
        });
      } else {
        setState(() {
          sgpa = 0.0;
        });
      }
    });
  }

  void calculateCGPA() {
    double totalSGPA = 0;
    int totalSemesters = 0;
    String ssem = _selectedSemester!;
    for (String semester in semesters) {
      _updateSemRef(semester);
      if (streamSnapshot?.data != null &&
          streamSnapshot!.data!.docs.isNotEmpty) {
        totalSGPA += sgpa; // Add the SGPA of the current semester to totalSGPA
        totalSemesters++; // Increment totalSemesters
      }
    }

    if (totalSemesters != 0) {
      setState(() {
        cgpa = totalSGPA / totalSemesters; // Calculate CGPA
      });
    } else {
      setState(() {
        cgpa = 0.0; // If no semesters found, set CGPA to 0.0
      });
    }

    _updateSemRef(ssem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: const Center(child: Text('CGPA')),
        actions: [
          DropdownButton<String>(
            value: _selectedSemester,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _updateSemRef(
                    newValue); // Update semRef when dropdown value changes
              }
            },
            items: semesters.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Text('SGPA: ${sgpa.toStringAsFixed(2)}'),
          Text('CGPA: ${cgpa.toStringAsFixed(2)}'),
        ],
      ),
      body: StreamBuilder(
        stream: semRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<DocumentSnapshot> semesterSubjects = snapshot.data!.docs
                .where((doc) =>
                    doc.reference.parent.parent!.id == _selectedSemester)
                .toList();

            return ListView.builder(
              itemCount: semesterSubjects.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    semesterSubjects[index];

                return GestureDetector(
                  onTap: () => _update(documentSnapshot),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 20),
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
                            text: (documentSnapshot['name'] +
                                ' : ' +
                                documentSnapshot['marks'].toString()),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.5),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSubject(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
