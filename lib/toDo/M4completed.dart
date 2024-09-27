import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubuddy/toDo/M4copy.dart';
import 'package:edubuddy/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class M4completed extends StatefulWidget {
  const M4completed({super.key});

  @override
  State<M4completed> createState() => _M4completedState();
}

class _M4completedState extends State<M4completed> {
  late CollectionReference colRef; // Declare colRef here
  Map<String, bool> checkboxStates = {}; // Map to store checkbox states

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        colRef = FirebaseFirestore.instance
            .collection('ToDoList')
            .doc(userEmail)
            .collection('ToDo');
      }
    }
  }

  Future<void> _delete(String productId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        // Define the collection reference correctly as colRef
        CollectionReference colRef = FirebaseFirestore.instance
            .collection('ToDoList')
            .doc(userEmail)
            .collection('ToDo');

        await colRef.doc(productId).delete();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('You have successfully deleted a product')));
      } else {
        print("User email is null");
      }
    } else {
      print("User is null");
    }
  }

  //bool isCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: const Center(child: Text('To Do List')),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 15), // Add space between appbar and buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 255, 237, 76), // Change button color here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const M4toDoList()),
                    );
                  },
                  child: const Text('Pending'),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 186, 255, 76), // Change button color here
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const M4completed()),
                    );
                  },
                  child: const Text('Completed'),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: colRef
                  .where('isCompleted', isEqualTo: true)
                  .snapshots(), // Filter data where isCompleted is false
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return ListView.builder(
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      final String documentId = documentSnapshot.id;
                      final bool isCompleted = checkboxStates[documentId] ??
                          true; // Get checkbox state
                      return Card(
                        margin: const EdgeInsets.all(10),
                        color: Colors.white, // Apply the background color here
                        child: ListTile(
                          title: Text(documentSnapshot['title']),
                          subtitle: Text(documentSnapshot['description']),
                          trailing: SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _delete(documentSnapshot.id)),
                              ],
                            ),
                          ),
                          leading: Checkbox(
                            checkColor: Colors.white,
                            value: isCompleted,
                            onChanged: (bool? value) {
                              setState(() async {
                                checkboxStates[documentId] =
                                    value!; // Update checkbox state in the map
                                await colRef.doc(documentId).update({
                                  "isCompleted": value,
                                });
                              });
                            },
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
    );
  }
}
