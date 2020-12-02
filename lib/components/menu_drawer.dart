import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/screens/map_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String activeMenu;

  Widget buildButton(Function function, String text) {
    return Container(
      padding: EdgeInsets.all(25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {function()},
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          text,
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("drawing Menu Drawer");
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            DrawerHeader(
              child: _buildAvatar(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // buildButton(() => print("hey"), "Voir mes parcours"),
                  buildButton(
                      () => FirebaseAuth.instance.signOut(), "Déconnexion"),
                  _buildMapBtn(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    var user = AuthService().getUser;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 25.0,
          child: Text(user.displayName[0] + user.displayName[1]),
          backgroundColor: Colors.grey,
          foregroundColor: Colors.white,
        ),
        SizedBox(width: 15.0),
        Text(AuthService().getUser.displayName),
      ],
    );
  }

  Widget _buildMapBtn() {
    return Container(
      padding: EdgeInsets.all(25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapScreen()),
          )
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Event map',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
}
