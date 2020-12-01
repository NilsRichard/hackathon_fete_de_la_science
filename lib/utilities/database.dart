import 'package:cloud_firestore/cloud_firestore.dart';

class DataBase {
  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection("programme");

  final CollectionReference ratings =
      FirebaseFirestore.instance.collection("ratings");

  Stream<QuerySnapshot> getEventsStream() {
    return eventCollection.snapshots();
  }

  Stream<QuerySnapshot> getNEventsStream(int n) {
    return eventCollection.limit(n).snapshots();
  }

  Stream<QuerySnapshot> getRating(String eventId) {
    return ratings.where("event_id", isEqualTo: eventId).snapshots();
  }

  Future rateEvent(String userId, String eventId, double rate) {
    var r = {
      'user_id': userId,
      'event_id': eventId,
      'rate': rate,
      'writtenDate': Timestamp.now().toDate()
    };
    return ratings
        .where("event_id", isEqualTo: eventId)
        .where("user_id", isEqualTo: userId)
        .snapshots()
        .first
        .then((snap) => {
              if (snap.size == 0)
                {
                  ratings
                      .add(r)
                      .then((value) => (value) => print('Event rated'))
                      .catchError(
                          (error) => print('Error wile rating ' + error))
                }
              else
                snap.docs.first.reference
                    .update(r)
                    .then((e) => {print('Changed vote')})
                    .catchError(
                        (error) => print('Error wile changing vote ' + error))
            });
  }
}

class Event {
  String id;
  List<DatesEvent> dates;

  String description;
  String descriptionLong;

  String image;
  List<String> keywords;

  String locationId;
  GeoPoint location;

  List<String> themes;
  String title;

  bool registrationNeeded;
  String openAgendaLink;
  String registrationEmail;
  String registrationPhone;
  String registrationLink;

  double rating; // TODO à implémenter

// Empty constructor
  Event();

  Event.fromJson(Map json, String id) {
    this.id = id;
    this.dates = DatesEvent.fromDynamicList(json["dates"]);
    this.description = json["description"];
    this.descriptionLong = json['description_long'];
    this.image = json['image'];

    this.keywords = stringListFromDynamicList(json['keywords']);

    this.locationId = json['location_id'];
    this.location = json['location'];

    this.themes = stringListFromDynamicList(json['themes']);

    this.title = json['title'];

    this.registrationNeeded = json['registration_required'];

    this.openAgendaLink = json['link'];
    this.registrationEmail = (json['registration_email'] != null
        ? json['registration_email'][0]
        : null);
    this.registrationPhone = (json['registration_phone'] != null
        ? json['registration_phone'][0]
        : null);
    this.registrationLink = (json['registration_link'] != null
        ? json['registration_link'][0]
        : null);

    this.rating = 3.5; // TODO
  }

  static List<String> stringListFromDynamicList(List<dynamic> list) {
    if (list == null) return null;
    List<String> ret = [];
    list.forEach((element) {
      ret.add(element + "");
    });
    return ret;
  }
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
  Timestamp end;
  Timestamp start;

  static List<DatesEvent> fromDynamicList(List<dynamic> list) {
    if (list == null) return null;
    List<DatesEvent> ret = [];
    list.forEach((element) {
      ret.add(DatesEvent.fromJson(element));
    });
    return ret;
  }

  DatesEvent.fromJson(Map json) {
    this.end = json["end"];
    this.start = json["start"];
  }
}
