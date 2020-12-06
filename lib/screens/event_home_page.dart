import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/screens/search_form.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class EventHomePage extends StatefulWidget {
  @override
  _EventHomePageState createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage> {
  var _events = DataBase().getEventsStream();
  void modifyEvents(Stream<QuerySnapshot> filteredEvents) {
    setState(() {
      _events = filteredEvents;
    });
  }

  Widget _buildEvent(Map<String, dynamic> event, String eventId) {
    Event ev = Event.fromJson(event, eventId);
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

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SearchForm(runSearch: modifyEvents),
            ),
          ),
          Flexible(fit: FlexFit.loose, child: _buildSuggestions()),
        ]);
  }

  Widget _buildSuggestions() {
    return StreamBuilder<QuerySnapshot>(
        stream: _events,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.separated(
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return _buildEvent(
                      snapshot.data.docs[i].data(), snapshot.data.docs[i].id);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              );
            } else {
              return Center(child: Text('There are no events'));
            }
          }
        });
  }
}
