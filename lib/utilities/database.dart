import 'package:cloud_firestore/cloud_firestore.dart';

class DataBase {
  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection("programme");

  Stream<QuerySnapshot> getEventsStream() {
    return eventCollection.snapshots();
  }

  Stream<QuerySnapshot> getNEventsStream(int n) {
    return eventCollection
        .limit(n)
        .snapshots();
  }
}

class Event {
  List<DatesEvent> dates;

  String description;
  String descriptionLong;

  String image;
  List<String> keywords;

  String locationId;
  GeoPoint location;

  String theme;
  String title;

  String openAgendaLink;
  String registrationEmail;
  String registrationPhone;
  String registrationLink;

  double rating; // à implémenter TODO
}

class Location {
  String id;
  GeoPoint location;

  String address;
  String country;
  String department;
  String name;
}

class DatesEvent {
  DateTime end;
  DateTime start;
}
