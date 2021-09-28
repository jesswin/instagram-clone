import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iinstagram/screens/Auth_Screen.dart';
import 'package:iinstagram/screens/DM_screen.dart';
import 'package:firebase_core/firebase_core.dart';

import './widgets/tab.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Instagram',
      theme:
          ThemeData(primaryColor: Color(0xFF000000), accentColor: Colors.white),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
      routes: {
        DMScreen.routeName: (context) => DMScreen(),
        Tabbarr.routeName: (context) => Tabbarr(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, userSnapShot) {
          if (userSnapShot.hasData) {
            print(userSnapShot);
            return Tabbarr();
          } else {
            return AuthScreen();
          }
        },
      ),
    );
  }
}
