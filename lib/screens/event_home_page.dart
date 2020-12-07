import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/components/search_form.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class EventHomePage extends StatefulWidget {
  @override
  _EventHomePageState createState() => _EventHomePageState();
}

class _EventHomePageState extends State<EventHomePage> {
  var _events = DataBase().getEventsStream();
  bool found;
  FilterData filters = FilterData.emptyFilter();
  void modifyEvents(Stream<QuerySnapshot> filteredEvents, FilterData _filters) {
    setState(() {
      _events = filteredEvents;
      filters = _filters;
    });
  }

  Event generateEvent(Map<String, dynamic> event, String eventId) {
    return Event.fromJson(event, eventId);
  }

  Widget applyFilters(Event ev) {
    //print("went into fliters");
    bool foundDate = false;
    if (filters.date != null) {
      //print("went into check date");
      int iter = 0;
      List<DatesEvent> dates = ev.dates;
      while (!foundDate && iter < dates.length) {
        DatesEvent possibleDate = dates.elementAt(iter);
        foundDate = possibleDate.containsDay(filters.date);
        iter++;
      }
    } else {
      foundDate = true;
    }
    bool foundLocation = true;
    if (filters.location != null && filters.location != "") {
      foundLocation = false;
      if (ev.address.contains(filters.location)) {
        foundLocation = true;
      }
    }
    if (foundDate && foundLocation) {
      found = true;
      return _buildListTile(ev);
    } else {
      found = false;
      return Container(width: 0, height: 0);
    }
  }

  Widget _buildListTile(Event ev) {
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
                  Event currentEvent = generateEvent(
                      snapshot.data.docs[i].data(), snapshot.data.docs[i].id);
                  return applyFilters(currentEvent);
                },
                separatorBuilder: (BuildContext context, int index) {
                  if(!found) {
                    return Container(width: 0, height: 0);
                  }
                  else{
                    return Divider();
                  }
                },
              );
            } else {
              return Center(child: Text('Aucun événement trouvé'));
            }
          }
        });
  }
}
