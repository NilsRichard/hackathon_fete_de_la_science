import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/screens/map_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';
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
            _buildMapBtn(),
            _buildBtn(),
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

  Widget _buildMapBtn() {
    return Container(
      padding: EdgeInsets.all(25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MapScreen()),
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


  Widget _buildBtn() {
    var event = new Event();
    event.image =
        'https://upload.wikimedia.org/wikipedia/commons/c/ce/UtrechtIconoclasm.jpg?1606828611159';
    event.title = "Titleqzd1";
    event.rating = 2.5;
    event.keywords = [
      "fromage",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "fraises",
      "science"
    ];
    event.registrationEmail = "something@gmail.com";
    event.registrationPhone = "+33 7 85 89 78 85";
    event.registrationLink = "http://google.com";
    event.description = "hey";
    event.descriptionLong =
        "LAnnexe Café est un endroit sympa avec de belles pierres apparentes, un bar en bois, des hauts tabourets avec la reproduction dune célèbre marque de bière et une ambiance comme on les aime dans ce quartier de fêtards du jeudi soir et même de toute la semaine. Retransmission de matchs, mix de DJ, happy-hours de 17h à 21 h, ça bouge et ça samuse. On" +
            "LAnnexe Café est un endroit sympa avec de belles pierres apparentes, un bar en bois, des hauts tabourets avec la reproduction dune célèbre marque de bière et une ambiance comme on les aime dans ce quartier de fêtards du jeudi soir et même de toute la semaine. Retransmission de matchs, mix de DJ, happy-hours de 17h à 21 h, ça bouge et ça samuse. On" +
            "LAnnexe Café est un endroit sympa avec de belles pierres apparentes, un bar en bois, des hauts tabourets avec la reproduction dune célèbre marque de bière et une ambiance comme on les aime dans ce quartier de fêtards du jeudi soir et même de toute la semaine. Retransmission de matchs, mix de DJ, happy-hours de 17h à 21 h, ça bouge et ça samuse. On";

    return Container(
      padding: EdgeInsets.all(25),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventInfosScreen(
                event: event,
              ),
            ),
          )
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'Event info',
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
