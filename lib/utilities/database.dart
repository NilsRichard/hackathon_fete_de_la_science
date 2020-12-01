import 'package:cloud_firestore/cloud_firestore.dart';

class DataBase {
  final CollectionReference tweetCollection =
      FirebaseFirestore.instance.collection("Tweets");

  Future uploadTweet(String pseudo, String contenu, String url) {
    return tweetCollection
        .add({
          'pseudo': pseudo,
          'contenu': contenu,
          'urlPhoto': url,
          'writtenDate': Timestamp.now().toDate()
        })
        .then((value) => (value) => print('Tweet uploaded'))
        .catchError((error) => print('Error wile uploading ' + error));
  }

  Stream<QuerySnapshot> getTweetsStream() {
    return tweetCollection.orderBy("writtenDate", descending: true).snapshots();
  }
}
