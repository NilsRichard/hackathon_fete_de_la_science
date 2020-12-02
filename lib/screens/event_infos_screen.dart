import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hackathon_fete_de_la_science/components/loading_circle.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
import 'package:hackathon_fete_de_la_science/components/star_rating.dart';
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
                image:
                    new DecorationImage(fit: BoxFit.fitHeight, image: image2))),
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
              onTapParkour: (String parkourId, String title) => {
                DataBase().addEventToParkour(
                    AuthService().getUser.email, widget.event.id, parkourId),
                Navigator.of(context).pop(),
                Fluttertoast.showToast(
                  msg: "Évènement ajouté à " + title,
                  toastLength: Toast.LENGTH_LONG,
                  gravity:
                      ToastGravity.BOTTOM, // also possible "TOP" and "CENTER"
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                ),
              },
            ),
          )
        },
      ),
    );
  }
}

class ParkourChoser extends StatefulWidget {
  final String title;
  final String eventId;
  final Function(String parkourId, String title) onTapParkour;

  ParkourChoser({
    @required this.title,
    @required this.eventId,
    @required this.onTapParkour,
  });

  @override
  ParkourChoserState createState() => ParkourChoserState();
}

class ParkourChoserState extends State<ParkourChoser> {
  TextEditingController _c;
  @override
  initState() {
    _c = new TextEditingController();
    super.initState();
  }

  Widget _buildParkour(BuildContext context, Map<String, dynamic> parkour,
      String parkourId, String eventId) {
    var title = parkour['title'] != null ? parkour['title'] : 'noName parkour';
    var published = parkour['published'] != null ? parkour['published'] : false;
    return ListTile(
      title: Text(title),
      subtitle: Text((published ? "publié" : "non publié")),
      onTap: () => {
        widget.onTapParkour(parkourId, title),
      },
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () => {
          updateName(parkourId),
        },
      ),
    );
  }

  Widget buildListParkours(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: DataBase().getMyParkours(AuthService().getUser.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingCircle();
          } else {
            if (snapshot.data.docs.length > 0) {
              return ListView.separated(
                itemCount: snapshot.data.docs.length,
                itemBuilder: /*1*/ (context, i) {
                  return _buildParkour(context, snapshot.data.docs[i].data(),
                      snapshot.data.docs[i].id, widget.eventId);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              );
            } else {
              return Center(child: Text("Vous n'avez pas encore de parcours"));
            }
          }
        });
  }

  Widget dialog(Widget child) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          top: Consts.padding + 15,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
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
        child: child,
      ),
    );
  }

  updateName(String parkourId) {
    showDialog(
        child: dialog(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new TextField(
                decoration: new InputDecoration(hintText: "Nouveau parcours"),
                controller: _c,
              ),
              new FlatButton(
                child: new Text("Valider"),
                onPressed: () {
                  DataBase().changeParkourTitle(parkourId,
                      _c.text.isEmpty ? "Nouveau parcours" : _c.text);
                  Navigator.pop(context);
                  _c.text = "";
                },
              )
            ],
          ),
        ),
        context: context);
  }

  @override
  Widget build(BuildContext context) {
    return dialog(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Parcours",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 15.0),
              RawMaterialButton(
                fillColor: Colors.green,
                shape: CircleBorder(),
                constraints: BoxConstraints.tightFor(
                  width: 35.0,
                  height: 35.0,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                onPressed: () => {
                  DataBase()
                      .addParkour(
                          AuthService().getUser.email, "Nouveau parcours")
                      .then(
                        (value) => {
                          DataBase().addEventToParkour(
                              AuthService().getUser.email,
                              widget.eventId,
                              value.id),
                          updateName(value.id),
                        },
                      ),
                },
              ),
            ],
          ),
          SizedBox(height: 15.0),
          Container(
            height: 250,
            child: Scrollbar(
              child: buildListParkours(context),
            ),
          ),
          SizedBox(height: 15.0),
          Align(
            alignment: Alignment.bottomRight,
            child: FlatButton(
              onPressed: () {
                Navigator.of(context).pop(); // To close the dialog
              },
              child: Text("Annuler"),
            ),
          ),
        ],
      ),
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
}
