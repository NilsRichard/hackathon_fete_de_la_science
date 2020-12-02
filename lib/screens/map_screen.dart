import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';
import 'package:latlong/latlong.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:firebase_core/firebase_core.dart';
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
  Geoflutterfire geo;
  MapController mapController;
  var popupController = PopupController();

  var markers = Map<String, OurMarker>();
  var eventsByPos = Map<LatLng, DocumentSnapshot>();
  Stream<List<DocumentSnapshot>> stream;

  @override
  void initState() {
    super.initState();

    print("map_screen -> initState");

    geo = Geoflutterfire();
    mapController = MapController();

    var _firestore = FirebaseFirestore.instance;

    var collectionReference = _firestore.collection('locations');
    /* stream = geo.collection(collectionRef: DataBase().eventCollection).within(
        center: geo.point(latitude: 48.11198, longitude: -1.67429),
        radius: 100,
        field: "location"); */
    stream = collectionReference.snapshots().map((qusn) => qusn.docs);
    stream.listen((List<DocumentSnapshot> documentList) {
      print("listen");
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
              plugins: <MapPlugin>[PopupMarkerPlugin()],
              center: LatLng(48.11198, -1.67429),
              zoom: 13.0
          ),
          layers: [
            TileLayerOptions(
              //final url = 'https://www.google.com/maps/vt/pb=!1m4!1m3!1i{z}!2i{x}!3i{y}!2m3!1e0!2sm!3i420120488!3m7!2sen!5e1105!12m4!1e68!2m2!1sset!2sRoadmap!4e0!5m1!1e0!23i4111425';
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
            ),
            PopupMarkerLayerOptions(
              markers: List<Marker>.of(markers.values),
              popupController: popupController,
              popupBuilder: (_, Marker marker) {
                if (marker is OurMarker) {
                  return Card(child: Text(marker.document.data()["name"]));
                }
                else {
                  return Card(child: Text("???"));
                }
              }
            )
          ]
        )
    );
  }
  
  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((document) {
      final GeoPoint point = document.data()['location'];
      print("marker:" + document.data()['name']);
      final _marker = OurMarker(document: document);
      setState(() {
        markers[document.id] = _marker;
      });
    });
    print("updateMarkers : end");
  }
}