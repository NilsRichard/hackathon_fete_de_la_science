import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

import 'event_infos_screen.dart';

class ParkourInfoScreen extends StatefulWidget {
  final String parkourId;
  String title;

  ParkourInfoScreen({
    @required this.title,
    @required this.parkourId,
  });

  @override
  ParkourInfoScreenState createState() => ParkourInfoScreenState();
}

class ParkourInfoScreenState extends State<ParkourInfoScreen> {
  TextEditingController _c;
  String title;
  @override
  initState() {
    _c = new TextEditingController();
    title = widget.title;
    super.initState();
  }

  buildEvent(BuildContext context, Event ev) {
    ImageProvider<Object> image = ev.image != null
        ? NetworkImage(ev.image)
        : AssetImage('images/empty.jpg');
    return ListTile(
      leading: Container(
        width: 50.0,
        height: 50.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          image: new DecorationImage(
            fit: BoxFit.fitHeight,
            image: image,
          ),
        ),
      ),
      title: Text(ev.title),
      subtitle: Text(ev.description, maxLines: 2),
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventInfosScreen(
              event: ev,
            ),
          ),
        )
      },
      trailing: Icon(Icons.chevron_right),
    );
  }

  Widget buildEventStream(BuildContext context, String eventId) {
    return StreamBuilder<DocumentSnapshot>(
        stream: DataBase().getEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.exists) {
              Event ev = Event.fromJson(snapshot.data.data(), snapshot.data.id);
              return buildEvent(context, ev);
            } else {
              return Center(child: Text('No information on this event'));
            }
          }
        });
  }

  Widget buildEvents() {
    return StreamBuilder<QuerySnapshot>(
        stream: DataBase().getParkourEvents(widget.parkourId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.separated(
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return buildEventStream(
                      context, snapshot.data.docs[i].data()['event_id']);
                },
              );
            } else {
              return Center(child: Text('There are no events'));
            }
          }
        });
  }

  Widget buildPage() {
    return Scaffold(
      body: Column(children: [
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              this.title,
              style: TextStyle(fontSize: title1FontSize),
              textAlign: TextAlign.center,
            ),
            SizedBox(width: 20.0),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => {
                updateName(widget.parkourId),
              },
            ),
          ],
        ),
        SizedBox(height: 20.0),
        Expanded(
          child: buildEvents(),
        ),
      ]),
      floatingActionButton: ElevatedButton(
        child: Text("Publier le parcours"),
        onPressed: () => {
          DataBase().publishParkour(widget.parkourId),
          Fluttertoast.showToast(
            msg: "Parcours publié",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER, // also possible "TOP" and "CENTER"
            backgroundColor: Colors.green,
            textColor: Colors.white,
          ),
        },
      ),
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
                      DataBase()
                          .changeParkourTitle(parkourId,
                              newTitle.isEmpty ? "Nouveau parcours" : newTitle)
                          .then((value) => setState(() {
                                this.title = newTitle;
                              }));
                      Navigator.of(context).pop();
                      _c.text = "";
                    },
                  ),
                  FlatButton(
                    child: new Text("Annuler"),
                    onPressed: () {
                      Navigator.of(context).pop();
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
      appBar: AppBar(
        title: Text('Fête de la Science'),
      ),
      endDrawer: MyDrawer(),
      body: buildPage(),
    );
  }
}
