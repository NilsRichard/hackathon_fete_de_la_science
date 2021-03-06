import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/screens/event_infos_screen.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';
import 'package:latlong/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

LatLng gpToLl(GeoPoint gp) {
  return LatLng(gp.latitude, gp.longitude);
}

class OurMarker extends Marker {
  OurMarker({@required this.document}) :
    super(
        anchorPos: AnchorPos.align(AnchorAlign.top),
        width: 30,
        height: 30,
        builder: (_) => Icon(Icons.location_on, size: 30),
        point: gpToLl(document.data()['location'])
    );

    final DocumentSnapshot document;
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController;
  var popupController = PopupController();

  var markers = Map<String, OurMarker>();
  var eventsByPos = Map<LatLng, DocumentSnapshot>();
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();

    mapController = MapController();

    var _firestore = FirebaseFirestore.instance;

    var collectionReference = _firestore.collection('locations');
    stream = collectionReference.snapshots().map((qusn) => qusn.docs);
    stream.listen((List<DocumentSnapshot> documentList) {
      _updateMarkers(documentList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("la carte")),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
              plugins: <MapPlugin>[MarkerClusterPlugin()],
              center: LatLng(48.11198, -1.67429),
              zoom: 6.0
          ),
          layers: [
            TileLayerOptions(
              //final url = 'https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
            ),
            MarkerClusterLayerOptions(
              maxClusterRadius: 100,
              size: Size(40, 40),
              fitBoundsOptions: FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
              markers: List<Marker>.of(markers.values),
              polygonOptions: PolygonOptions(
                borderColor: Colors.blueAccent,
                color: Colors.black12,
                borderStrokeWidth: 3,
              ),
              builder: (context, markers) {
                return FloatingActionButton(
                    child: Text(markers.length.toString()),
                    onPressed: null,
                    heroTag: markers.hashCode,
                );
              },
              popupOptions: PopupOptions(
                popupSnap: PopupSnap.top,
                popupController: popupController,
                popupBuilder: (_, Marker marker) {
                  if (marker is OurMarker) {
                    return Card(
                        child: ConstrainedBox(
                            constraints: BoxConstraints.loose(Size(300,290)),
                            child: Column(

                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    child: Text(marker.document.data()["name"], style: TextStyle(fontSize: 16),),
                                  ),
                                  Expanded(
                                      child:
                                      _buildSuggestions(
                                          DataBase().eventCollection
                                              .where("location_id", isEqualTo: marker.document.id)
                                              .snapshots()
                                      )
                                  )
                                ]
                            )
                        )
                    );
                  }
                  else {
                    return Card(child: Text("???"));
                  }
                }
              )
            )
          ]
        )
    );
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((document) {
      final _marker = OurMarker(document: document);
      setState(() {
        markers[document.id] = _marker;
      });
    });
  }


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


  Widget _buildSuggestions(Stream<QuerySnapshot> eventStream) {
    return StreamBuilder<QuerySnapshot>(
        stream: eventStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                //shrinkWrap: true,
                padding: EdgeInsets.all(8.0),
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