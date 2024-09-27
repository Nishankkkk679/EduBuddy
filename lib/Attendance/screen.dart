import 'package:edubuddy/Document/screen.dart';
import 'package:edubuddy/auth/screens/signin_screen.dart';
import 'package:edubuddy/cgpa/cgpa.dart';
import 'package:edubuddy/notes/screens/note_screen.dart';
import 'package:edubuddy/toDo/M4copy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:edubuddy/home_screen.dart';

class WorkInProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
          title: const Center(
        child: Text('Work In Progress'),
      )),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 250.0,
              child: TyperAnimatedTextKit(
                isRepeatingAnimation: true,
                speed: Duration(milliseconds: 50),
                text: ["Work in Progress"],
                textStyle: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            EmojiTextAnimation(),
          ],
        ),
      ),
    );
  }
}

class EmojiTextAnimation extends StatefulWidget {
  @override
  _EmojiTextAnimationState createState() => _EmojiTextAnimationState();
}

class _EmojiTextAnimationState extends State<EmojiTextAnimation> {
  late final parser = EmojiParser();
  final emojis = [
    'sweat_smile',
    'wrench',
  ];
  int currentEmojiIndex = 0;

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  void startAnimation() {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        currentEmojiIndex = (currentEmojiIndex + 1) % emojis.length;
      });
      startAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emoji = parser.get(':' + emojis[currentEmojiIndex] + ':').code;
    return Text(
      emoji,
      style: TextStyle(fontSize: 50),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: WorkInProgressPage(),
  ));
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
                MaterialPageRoute(builder: (context) => const HomeScreen()),
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
