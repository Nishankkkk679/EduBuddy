import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edubuddy/toDo/M4completed.dart';
import 'package:edubuddy/widgets/NavBar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class M4toDoList extends StatefulWidget {
  const M4toDoList({super.key});

  @override
  State<M4toDoList> createState() => _M4toDoListState();
}

class _M4toDoListState extends State<M4toDoList> {
  // text fields' controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _isCompleted = TextEditingController();

  late CollectionReference colRef; // Declare colRef here
  Map<String, bool> checkboxStates = {}; // Map to store checkbox states

  final List<String> categoryOptions = ['Urgent', 'Important', 'Not'];

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

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final formattedDate = DateFormat.yMMMd().format(pickedDate);
      setState(() {
        _dateController.text =
            formattedDate; // Update the text field with the formatted date
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime
            .format(context); // Update the text field with the selected time
      });
    }
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    print("Create");
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? userEmail = user.email;
      if (userEmail != null) {
        // Define the collection reference correctly as colRef
        CollectionReference colRef = FirebaseFirestore.instance
            .collection('ToDoList')
            .doc(userEmail)
            .collection('ToDo');

        await showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext ctx) {
              return Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _categoryController.text.isEmpty
                          ? null
                          : _categoryController.text,
                      items: categoryOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _categoryController.text =
                              value ?? ''; // Update the value of the controller
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        suffixIcon: IconButton(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        suffixIcon: IconButton(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: const Text('Create'),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final String desc = _descriptionController.text;
                        final String catg = _categoryController.text;
                        final String date = _dateController.text;
                        final String time = _timeController.text;
                        if (title != "") {
                          await colRef.add({
                            "title": title,
                            "description": desc,
                            "category": catg,
                            "date": date,
                            "time": time,
                            "isCompleted": false
                          });

                          _titleController.text = '';
                          _descriptionController.text = '';
                          _categoryController.text = '';
                          _dateController.text = '';
                          _timeController.text = '';
                          _isCompleted.text = '';
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                ),
              );
            });
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
        // Define the collection reference correctly as colRef
        CollectionReference colRef = FirebaseFirestore.instance
            .collection('ToDoList')
            .doc(userEmail)
            .collection('ToDo');

        if (documentSnapshot != null) {
          setState(() {
            _titleController.text = documentSnapshot['title'];
            _descriptionController.text = documentSnapshot['description'];
            _categoryController.text = documentSnapshot['category'];
            _dateController.text = documentSnapshot['date'];
            _timeController.text = documentSnapshot['time'];
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
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _categoryController.text.isEmpty
                          ? null
                          : _categoryController.text,
                      items: categoryOptions.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _categoryController.text =
                              value ?? ''; // Update the value of the controller
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                    ),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date',
                        suffixIcon: IconButton(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    TextField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        labelText: 'Time',
                        suffixIcon: IconButton(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      child: const Text('Update'),
                      onPressed: () async {
                        final String title = _titleController.text;
                        final String desc = _descriptionController.text;
                        final String catg = _categoryController.text;
                        final String date = _dateController.text;
                        final String time = _timeController.text;
                        if (title != "") {
                          await colRef.doc(documentSnapshot?.id).update({
                            "title": title,
                            "description": desc,
                            "category": catg,
                            "date": date,
                            "time": time
                          });
                          setState(() {
                            _titleController.text = '';
                            _descriptionController.text = '';
                            _categoryController.text = '';
                            _dateController.text = '';
                            _timeController.text = '';
                          });
                          Navigator.of(context).pop();
                        }
                      },
                    )
                  ],
                ),
              );
            });
      } else {
        print("User email is null");
      }
    } else {
      print("User is null");
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

  bool isCompleted = false;

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
                  .where('isCompleted', isEqualTo: false)
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
                          false; // Get checkbox state
                      final String category = documentSnapshot['category'];

                      // Define background color based on category
                      Color backgroundColor;
                      switch (category) {
                        case 'Urgent':
                          backgroundColor = const Color.fromARGB(255, 236, 113,
                              113); // Set background color for 'Urgent'
                          break;
                        case 'Important':
                          backgroundColor = const Color.fromARGB(255, 250, 190,
                              112); // Set background color for 'Important'
                          break;
                        case 'Not':
                          backgroundColor = const Color.fromARGB(255, 158, 252,
                              207); // Set background color for 'Not'
                          break;
                        default:
                          backgroundColor =
                              Colors.white; // Default background color
                      }

                      return Card(
                        margin: const EdgeInsets.all(10),
                        color:
                            backgroundColor, // Apply the background color here
                        child: ListTile(
                          title: Text(documentSnapshot['title']),
                          subtitle: Text(documentSnapshot['description']),
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
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _create(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
