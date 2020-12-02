import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/screens/search_form.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class EventHomePage extends StatefulWidget {
  @override
  _EventHomePageState createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage> {
  final _events = DataBase().getEventsStream();

  Widget _buildEvent(Map<String, dynamic> event, String eventId) {
    Event ev = Event.fromJson(event, eventId);
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30.0,
          child: Image.network(ev.image),
          backgroundColor: Colors.transparent,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SearchForm(),
            ),
          ),
          Flexible(
              fit: FlexFit.loose,
              child: _buildSuggestions()
          ),
        ]
    );
  }

  Widget _buildSuggestions() {
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
                  return _buildEvent(
                      snapshot.data.docs[i].data(), snapshot.data.docs[i].id);
                },
              );
            } else {
              return Center(child: Text('There are no events'));
            }
          }
        });
  }
}
