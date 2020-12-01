import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _events = DataBase().getEventsStream();

  Widget _buildEvent(Map<String, dynamic> event) {
    var title = event['title'] != null ? event['title'] : 'noName event';
    var date = event['date_start'] != null ? event['date_start'] : null;
    var image =
        'http://www.holo3.com/wp-content/uploads/2017/07/image-homme-anonyme.png';
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        child: Image.network(image),
        backgroundColor: Colors.transparent,
      ),
      title: Text(title),
      subtitle: Text(
          date != null ? date.toDate().toString() : "start date is unknown"),
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventInfosScreen(
              event: Event.fromJson(event),
            ),
          ),
        )
      },
      trailing: Icon(Icons.chevron_right),
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
                  return _buildEvent(snapshot.data.docs[i].data());
                },
              );
            } else {
              return Center(child: Text('There are no events'));
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'home',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Text('Evenements', textScaleFactor: 1.5),
                Text('Parcours', textScaleFactor: 1.5),
              ],
            ),
            title: Text('Faites(fête) de la science'),
          ),
          endDrawer: MyDrawer(),
          body: TabBarView(
            children: [
              _buildSuggestions(),
              Icon(Icons.directions_run),
            ],
          ),
        ),
      ),
    );
  }
}
