import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

import 'event_infos_screen.dart';

class ParkourInfoScreen extends StatelessWidget {
  final String parkourId;
  final String title;

  ParkourInfoScreen({this.parkourId, this.title});

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
        stream: DataBase().getParkourEvents(parkourId),
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
    return Column(children: [
      SizedBox(height: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: title1FontSize),
            textAlign: TextAlign.center,
          ),
          SizedBox(width: 20.0),
          IconButton(icon: Icon(Icons.edit), onPressed: null),
          IconButton(icon: Icon(Icons.share), onPressed: null)
        ],
      ),
      SizedBox(height: 20.0),
      Expanded(
        child: buildEvents(),
      ),
    ]);
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
