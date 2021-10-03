import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoveIcon {
  Icon normal = Icon(
    FontAwesomeIcons.solidHeart,
    color: Colors.grey[500],
  );
  Icon bold = Icon(
    FontAwesomeIcons.solidHeart,
    color: Colors.red,
  );
}

class BookmarkIcon {
  Icon normal = Icon(Icons.bookmark_border);
  Icon bold = Icon(Icons.bookmark);
}
