import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/utilities/auth_service.dart';
import 'package:hackathon_fete_de_la_science/utilities/constants.dart';
import 'package:hackathon_fete_de_la_science/utilities/database.dart';
import 'package:url_launcher/url_launcher.dart';

class EventInfosScreen extends StatefulWidget {
  final Event event;
  EventInfosScreen({Key key, @required this.event}) : super(key: key);

  @override
  EventInfosScreenState createState() => new EventInfosScreenState();
}

class EventInfosScreenState extends State<EventInfosScreen> {
  Future<void> launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget buildInfoElement(Icon icon, String info, Function onPressed) {
    return Row(
      children: [
        SizedBox(width: 25.0),
        IconButton(
          icon: icon,
          onPressed: onPressed,
        ),
        SizedBox(width: 25.0),
        Text(
          info.length <= 30 ? info : info.substring(0, 30) + "...",
          style: TextStyle(
            fontSize: normalFontSize, // defined in utilities/constants.dart
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Widget buildKeywords() {
    if (widget.event.keywords == null) return Text("Pas de mot-clé");
    String str = "";
    widget.event.keywords.forEach((element) {
      if (element == widget.event.keywords.last)
        str += element;
      else
        str += element + ", ";
    });
    return Text(
      str,
      style: TextStyle(
        fontSize: normalFontSize, // defined in utilities/constants.dart
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget buildInformation() {
    if (widget.event.registrationNeeded != null &&
        !widget.event.registrationNeeded)
      return Text("Inscription non requise.");

    var email = widget.event.registrationEmail;
    var phone = widget.event.registrationPhone;
    var website = widget.event.registrationLink;

    List<Widget> widgets = [];

    if (email != null) {
      widgets.add(buildInfoElement(
          Icon(Icons.mail), email, () => launchUrl("mailto:" + email)));
      widgets.add(SizedBox(height: 15.0));
    }
    if (phone != null) {
      widgets.add(buildInfoElement(
          Icon(Icons.phone), phone, () => launchUrl("tel:" + phone)));
      widgets.add(SizedBox(height: 15.0));
    }
    if (website != null) {
      widgets.add(buildInfoElement(
          Icon(Icons.public), website, () => launchUrl(website)));
      widgets.add(SizedBox(height: 15.0));
    }

    return Column(
      children: widgets,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  Widget buildTitle2(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: title2FontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget buildRating() {
    return StreamBuilder<QuerySnapshot>(
        stream: DataBase().getRating(widget.event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              double total = 0;
              snapshot.data.docs.forEach((element) {
                total += element["rate"];
              });
              return Center(
                child: StarRating(
                  rating: total / snapshot.data.docs.length,
                  totalRatings: snapshot.data.docs.length,
                  onRatingChanged: (rating) => {
                    DataBase().rateEvent(
                        AuthService().getUser.email, widget.event.id, rating)
                  },
                ),
              );
            } else {
              return Center(
                child: StarRating(
                  rating: 0,
                  onRatingChanged: (rating) => {
                    DataBase().rateEvent(
                        AuthService().getUser.email, widget.event.id, rating)
                  },
                ),
              );
            }
          }
        });
  }

  Widget buildTop() {
    ImageProvider<Object> image2 = widget.event.image != null
        ? NetworkImage(widget.event.image)
        : AssetImage('images/empty.jpg');

    return Column(
      children: [
        SizedBox(height: 30.0),
        Container(
            width: 190.0,
            height: 190.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(fit: BoxFit.fill, image: image2))),
        SizedBox(height: 15.0),
        Text(
          widget.event.title,
          style: TextStyle(fontSize: title1FontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15.0),
        buildRating(),
        SizedBox(height: 15.0),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                buildTitle2("Description :"),
                SizedBox(height: 15.0),
                Text(
                  widget.event.descriptionLong,
                  style: TextStyle(
                    fontSize: normalFontSize,
                  ),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 15.0),
                // buildTitle2("Lieu"),
                // SizedBox(height: 15.0),
                // buildLieu(),
                SizedBox(height: 15.0),
                buildTitle2("Inscription :"),
                SizedBox(height: 15.0),
                buildInformation(),
                SizedBox(height: 15.0),
                buildTitle2("Mot-clés :"),
                SizedBox(height: 15.0),
                buildKeywords(),
              ],
            )),
        SizedBox(height: 100.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fête de la Science'),
      ),
      endDrawer: MyDrawer(),
      body: ListView(
        children: [
          buildTop(),
        ],
      ),
      floatingActionButton: ElevatedButton(
        child: Text("Ajouter au parcours"),
        onPressed: () => {
          showDialog(
            context: context,
            builder: (BuildContext context) => ParkourChoser(
              title: "Success",
              eventId: widget.event.id,
            ),
          )
        },
      ),
    );
  }
}

typedef void RatingChangeCallback(double rating);

class StarRating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final int totalRatings;

  StarRating(
      {this.starCount = 5,
      this.rating = .0,
      this.onRatingChanged,
      this.color,
      this.totalRatings = 0});

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Theme.of(context).buttonColor,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
      );
    }
    return new InkResponse(
      onTap:
          onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ws =
        new List.generate(starCount, (index) => buildStar(context, index));
    ws.add(Text("(" +
        totalRatings.toString() +
        " note" +
        (totalRatings > 1 ? "s)" : ")")));
    return new Row(children: ws, mainAxisAlignment: MainAxisAlignment.center);
  }
}

class ParkourChoser extends StatelessWidget {
  final String title;
  final String eventId;

  ParkourChoser({
    @required this.title,
    @required this.eventId,
  });

  Widget _buildParkour(
      Map<String, dynamic> parkour, String parkourId, String eventId) {
    var title = parkour['title'] != null ? parkour['title'] : 'noName parkour';
    var published = parkour['published'] != null ? parkour['published'] : false;
    return ListTile(
      leading: CircleAvatar(
        radius: 20.0,
        child: Text(title[0]),
        backgroundColor: Colors.grey,
      ),
      title: Text(title),
      subtitle: Text((published ? "publié" : "non publié")),
      onTap: () => {
        DataBase()
            .addEventToParkour(AuthService().getUser.email, eventId, parkourId)
      },
      trailing: Icon(Icons.add),
    );
  }

  Widget buildListParkours() {
    return StreamBuilder<QuerySnapshot>(
        stream: DataBase().getMyParkours(AuthService().getUser.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return _buildParkour(snapshot.data.docs[i].data(),
                      snapshot.data.docs[i].id, eventId);
                },
              );
            } else {
              return Center(child: Text("Vous n'avez pas encore de parcours"));
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          top: Consts.avatarRadius + Consts.padding,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        margin: EdgeInsets.only(top: Consts.avatarRadius),
        decoration: new BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(Consts.padding),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(children: [
          RaisedButton(
            child: Text("Ajouter dans un nouveau parcours"),
            onPressed: () => {
              DataBase().addParkour(AuthService().getUser.email, "title").then(
                  (value) => {
                        DataBase().addEventToParkour(
                            AuthService().getUser.email, eventId, value.id)
                      })
            },
          ),
          SizedBox(height: 15.0),
          Expanded(child: buildListParkours()),
        ]),
      ),
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}
