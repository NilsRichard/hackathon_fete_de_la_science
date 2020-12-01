import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/screens/home_page.dart';
import 'package:hackathon_fete_de_la_science/screens/login_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      stream: AuthService().user,
      child: MaterialApp(
        title: 'Hackathon',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: Wrapper(),
      ),
    );
  }
}

class Wrapper extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return user != null ? HomePage() : LoginScreen();
  }
}
