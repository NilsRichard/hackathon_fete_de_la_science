import 'package:flutter/material.dart';
import 'package:hackathon_fete_de_la_science/components/menu_drawer.dart';
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
        Center(
          child: StarRating(
            rating: widget.event.rating,
            onRatingChanged: (rating) =>
                setState(() => widget.event.rating = rating),
          ),
        ),
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
        onPressed: () => {print('Clicked')},
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

  StarRating(
      {this.starCount = 5, this.rating = .0, this.onRatingChanged, this.color});

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
    return new Row(
        children:
            new List.generate(starCount, (index) => buildStar(context, index)),
        mainAxisAlignment: MainAxisAlignment.center);
  }
}
