import 'package:cloud_firestore/cloud_firestore.dart';

class DataBase {
  final CollectionReference eventCollection =
      FirebaseFirestore.instance.collection("programme");

  Stream<QuerySnapshot> getEventsStream() {
    return eventCollection.orderBy("date_start", descending: true).snapshots();
  }

  Stream<QuerySnapshot> getNEventsStream(int n) {
    return eventCollection.orderBy("date_start", descending: true).limit(n).snapshots();
  }
}
