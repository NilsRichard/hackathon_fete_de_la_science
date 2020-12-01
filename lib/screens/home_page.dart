import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _tweets = DataBase().getTweetsStream();
  final _formKey = GlobalKey<FormState>();
  String _content;

  Future<void> tweet() async {
    var user = AuthService().getUser;
    final form = _formKey.currentState;
    form.save();
    if (form.validate()) {
      print("$_content");
      if (_content != null) {
        print('tweeting');
        DataBase().uploadTweet(user.displayName, _content, user.photoURL);
        form.reset();
      }
    }
  }

  Widget _buildRow(Map<String, dynamic> tweet) {
    var title = tweet['pseudo'] != null ? tweet['pseudo'] : 'oups';
    var content = tweet['contenu'] != null ? tweet['contenu'] : 'oups';
    var image = tweet['urlPhoto'] != null
        ? tweet['urlPhoto']
        : 'http://www.holo3.com/wp-content/uploads/2017/07/image-homme-anonyme.png';
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        child: Image.network(image),
        backgroundColor: Colors.transparent,
      ),
      title: Text(title),
      subtitle: Text(content),
    );
  }

  Widget _buildSuggestions() {
    return StreamBuilder<QuerySnapshot>(
        stream: _tweets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.separated(
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return _buildRow(snapshot.data.docs[i].data());
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              );
            } else {
              return Center(child: Text('There is no tweet'));
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    MaterialApp tp2 = MaterialApp(
      title: 'TWISTIC',
      home: Scaffold(
        appBar: AppBar(
          title: Text('TWISTIC'),
        ),
        drawer: MyDrawer(),
        body: Column(
          children: [
            Expanded(child: _buildSuggestions()),
            Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  onSaved: (value) => _content = value,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Colors.black,
                      ),
                      tooltip: 'Send a tweet',
                      onPressed: () {
                        print('trying to tweet');
                        tweet();
                      },
                    ),
                    hintText: 'What are you thinking ?',
                    hintStyle: k2HintTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return tp2;
  }
}
