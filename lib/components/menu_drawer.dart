import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:validators/validators.dart';

class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String activeMenu;

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
            _buildLogOutBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    var user = AuthService().getUser;
    return Row(children: [
      CircleAvatar(
        radius: 30.0,
        child: Text(user.displayName[0] + user.displayName[1]),
        backgroundColor: Colors.transparent,
      ),
      Padding(
          padding: EdgeInsets.all(15),
          child: Text(AuthService().getUser.displayName)),
    ]);
  }

  CircleAvatar _buildAvatarFromPseudo(var pseudo) {
    String str = "";
    pseudo.asPascalCase.runes.forEach((int rune) {
      var character = new String.fromCharCode(rune);
      if (isUppercase(character)) str += character;
    });
    return CircleAvatar(child: Text(str));
  }

  Widget _buildLogOutBtn() {
    return Container(
      padding: EdgeInsets.all(25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {FirebaseAuth.instance.signOut()},
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'LOG OUT',
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
