// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Attendance extends StatefulWidget {
  const Attendance({Key? key}) : super(key: key);

  @override
  _AttendanceState createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  late CollectionReference colRef;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();

  double overallAttendance = 0.0;

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        colRef = FirebaseFirestore.instance
            .collection('Attendance')
            .doc(userEmail)
            .collection('Attend');
      }
    }
  }

  Future<void> _addSubject([DocumentSnapshot? documentSnapshot]) async {
    print("ADD");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                // Add SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Subject Name'),
                    ),
                    TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(labelText: 'Goal'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: const Text('ADD'),
                      onPressed: () async {
                        final String name = _nameController.text;
                        final int goal =
                            int.tryParse(_goalController.text) ?? 0;
                        const int attended = 0;
                        const int total = 0;
                        if (name.isNotEmpty) {
                          await colRef.add({
                            "name": name,
                            "goal": goal,
                            "attended": attended,
                            "total": total,
                          });

                          _nameController.text = '';
                          _goalController.text = '';
                          Navigator.of(context).pop();
                          updateOverallAttendance(); // Call to update overall attendance
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      } else {
        print("User email is null");
      }
    } else {
      print("User is null");
    }
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    print("Update");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        if (documentSnapshot != null) {
          setState(() {
            _nameController.text = documentSnapshot['name'];
            _goalController.text = documentSnapshot['goal'].toString();
          });
        }

        await showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (BuildContext ctx) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                // Add SingleChildScrollView
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Subject Name'),
                    ),
                    TextField(
                      controller: _goalController,
                      decoration: const InputDecoration(labelText: 'Goal'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () async {
                        final String name = _nameController.text;
                        final int goal =
                            int.tryParse(_goalController.text) ?? 0;

                        if (name.isNotEmpty) {
                          await colRef.doc(documentSnapshot?.id).update({
                            "name": name,
                            "goal": goal,
                          });
                          setState(() {
                            _nameController.text = '';
                            _goalController.text = '';
                          });
                          Navigator.of(context).pop();
                          updateOverallAttendance(); // Call to update overall attendance
                        }
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      } else {
        print("User email is null");
      }
    } else {
      print("User is null");
    }
  }

  Future<void> _delete(String id) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        await colRef.doc(id).delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have successfully deleted a product'),
          ),
        );
        updateOverallAttendance(); // Call to update overall attendance
      } else {
        print("User email is null");
      }
    } else {
      print("User is null");
    }
  }

  Future<void> incrementAttended([DocumentSnapshot? documentSnapshot]) async {
    User? user = FirebaseAuth.instance.currentUser;
    int attended = 0;
    int total = 0;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        if (documentSnapshot != null) {
          attended = documentSnapshot['attended'] ?? 0;
          total = documentSnapshot['total'] ?? 0;
          total++;
          attended++;

          await colRef.doc(documentSnapshot.id).update({
            "total": total,
            "attended": attended,
          });
          updateOverallAttendance(); // Call to update overall attendance
        } else {
          print("DocumentSnapshot is null");
        }
      }
    }
  }

  Future<void> missed([DocumentSnapshot? documentSnapshot]) async {
    User? user = FirebaseAuth.instance.currentUser;
    int total = 0;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        if (documentSnapshot != null) {
          total = documentSnapshot['total'] ?? 0;
          total++;
          await colRef.doc(documentSnapshot.id).update({
            "total": total,
          });
          updateOverallAttendance(); // Call to update overall attendance
        } else {
          print("DocumentSnapshot is null");
        }
      }
    }
  }

  Future<double> attendPercentage([DocumentSnapshot? documentSnapshot]) async {
    User? user = FirebaseAuth.instance.currentUser;
    int attended = 0;
    int total = 0;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        if (documentSnapshot != null) {
          attended = documentSnapshot['attended'] ?? 0;
          total = documentSnapshot['total'] ?? 0;
        } else {
          print("DocumentSnapshot is null");
          return -1;
        }

        if (total == 0) {
          return 0.0; // Return 0.0 when total is 0
        } else {
          double percentage = (attended / total) * 100;
          if (percentage.isNaN) {
            percentage = 0.0;
          }
          return percentage; // Check for NaN and return 0.0
        }
      }
    }
    return -1;
  }

  Future<int> lecsToAttend([DocumentSnapshot? documentSnapshot]) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        if (documentSnapshot != null) {
          int goal = documentSnapshot['goal'] ?? 0;
          int total = documentSnapshot['total'] ?? 0;
          double currentPercentage = await attendPercentage(documentSnapshot);
          if (currentPercentage >= goal) {
            return 0;
          }
          double requiredPercentage = goal - currentPercentage;
          int classesNeeded =
              ((requiredPercentage / 100) * total / (1 - goal / 100)).ceil();
          return classesNeeded;
        } else {
          print("DocumentSnapshot is null");
          return -1;
        }
      } else {
        print("User email is null");
        return -1;
      }
    } else {
      print("User is null");
      return -1;
    }
  }

  Future<double> calculateOverallAttendance() async {
    double overallAttendance = 0.0;
    int subjectCount = 0;

    // Get the documents from Firestore
    QuerySnapshot snapshot = await colRef.get();

    // Calculate attendance for each subject
    snapshot.docs.forEach((DocumentSnapshot document) {
      int attended = document['attended'] ?? 0;
      int total = document['total'] ?? 0;

      if (total > 0) {
        double attendancePercentage = (attended / total) * 100;
        overallAttendance += attendancePercentage;
        subjectCount++;
      }
    });

    // Calculate average attendance
    if (subjectCount > 0) {
      overallAttendance /= subjectCount;
    }

    return overallAttendance;
  }

  Future<void> updateOverallAttendance() async {
    double newOverallAttendance = await calculateOverallAttendance();
    setState(() {
      overallAttendance = newOverallAttendance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Manager'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 15),
          FutureBuilder<double>(
            future: calculateOverallAttendance(),
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final overallAttendance = snapshot.data ?? 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Overall Attendance: ${overallAttendance.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: colRef.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          title: Text(documentSnapshot['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Classes Attended : ${documentSnapshot['attended']}'),
                              Text(
                                  'Classes Missed   : ${documentSnapshot['total'] - documentSnapshot['attended']}'),
                              Text(
                                  'Attended : ${(documentSnapshot['attended'] * 100 / documentSnapshot['total']).toStringAsFixed(2)}%'),
                              Text('Goal : ${documentSnapshot['goal']}%'),
                              FutureBuilder<int>(
                                future: lecsToAttend(documentSnapshot),
                                builder: (BuildContext context,
                                    AsyncSnapshot<int> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text(
                                        'Loading...'); // Placeholder while waiting for the result
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      'Classes needed to attend to get back on track : ${snapshot.data}',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      missed(documentSnapshot);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      incrementAttended(documentSnapshot);
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _update(documentSnapshot),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSubject(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
