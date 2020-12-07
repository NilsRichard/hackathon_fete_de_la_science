import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/screens/parkour_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class ParkoursPage extends StatefulWidget {
  @override
  _ParkoursPageState createState() => _ParkoursPageState();
}

class _ParkoursPageState extends State<ParkoursPage> {
  TextEditingController _c;
  String title;
  @override
  initState() {
    _c = new TextEditingController();
    super.initState();
  }

  var _events = DataBase().getPublishedParkours();
  bool seeMyParkours = false;

  Widget buildParkour(Map<String, dynamic> parkour, String parkourId) {
    var title = parkour['title'] != null ? parkour['title'] : "no title";
    var subtitle = (seeMyParkours
        ? "Créé le " + parkour['writtenDate'].toDate().toString()
        : "Published by " + parkour['user_id']);
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ParkourInfoScreen(
                    parkourId: parkourId,
                    title: title,
                  )),
        )
      },
      trailing: Icon(Icons.chevron_right),
    );
  }

  Widget buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Checkbox(
          value: seeMyParkours,
          onChanged: (bool newValue) {
            setState(() {
              seeMyParkours = newValue;
            });
            if (newValue)
              _events = DataBase().getMyParkours(AuthService().getUser.email);
            else
              _events = DataBase().getPublishedParkours();
          },
        ),
        Text(
          "Voir mes parcours",
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }

  updateName(String parkourId) {
    showDialog(
        useRootNavigator: false,
        child: dialog(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(hintText: "Nouveau parcours"),
                controller: _c,
              ),
              ButtonBar(
                children: [
                  FlatButton(
                    child: new Text("Valider"),
                    onPressed: () {
                      String newTitle = _c.text;
                      DataBase().changeParkourTitle(parkourId,
                          newTitle.isEmpty ? "Nouveau parcours" : newTitle);

                      Navigator.of(context).pop();
                      _c.text = "";
                    },
                  ),
                  FlatButton(
                    child: new Text("Annuler"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _c.text = "";
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          buildTopBar(),
          SizedBox(height: 15.0),
          Expanded(
            child: buildParkours(),
          ),
          SizedBox(height: 15.0),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => {
                DataBase()
                    .addParkour(AuthService().getUser.email, "Nouveau parcours")
                    .then((value) => {
                          updateName(value.id),
                        })
              }),
    );
  }

  Widget buildParkours() {
    return StreamBuilder<QuerySnapshot>(
        stream: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return buildParkour(
                      snapshot.data.docs[i].data(), snapshot.data.docs[i].id);
                },
              );
            } else {
              return Center(
                  child: Text(seeMyParkours
                      ? "Vous n'avez pas encore de parcours"
                      : "Personne n\'a publié de parcours"));
            }
          }
        });
  }
}
