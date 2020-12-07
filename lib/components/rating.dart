import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

typedef void RatingChangeCallback(double rating);

class Rating extends StatelessWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;
  final int totalRatings;
  final double marginBetween;

  final IconData emptyIcon;
  final IconData halfIcon;
  final IconData fullIcon;

  Rating(
      {this.marginBetween = 0,
      this.emptyIcon = Icons.star_border,
      this.halfIcon = Icons.star_half,
      this.fullIcon = Icons.star,
      this.starCount = 5,
      this.rating = .0,
      this.onRatingChanged,
      this.color,
      this.totalRatings = 0});

  Widget buildStar(BuildContext context, int index) {
    FaIcon icon;
    if (index >= rating) {
      icon = new FaIcon(
        emptyIcon,
        color: Theme.of(context).buttonColor,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new FaIcon(
        halfIcon,
        color: color ?? Theme.of(context).primaryColor,
      );
    } else {
      icon = new FaIcon(
        fullIcon,
        color: color ?? Theme.of(context).primaryColor,
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: marginBetween),
      child: InkResponse(
        onTap:
            onRatingChanged == null ? null : () => onRatingChanged(index + 1.0),
        child: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ws =
        new List.generate(starCount, (index) => buildStar(context, index));

    if (totalRatings != 0)
      ws.add(Text("(" +
          totalRatings.toString() +
          " note" +
          (totalRatings > 1 ? "s)" : ")")));
    return new Row(children: ws, mainAxisAlignment: MainAxisAlignment.center);
  }
}
