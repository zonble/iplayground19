import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:iplayground19/api/api.dart';

class RoomLabel extends StatelessWidget {
  final Session session;

  const RoomLabel({
    Key key,
    @required this.session,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = () {
      switch (session.roomName) {
        case '101':
          return Colors.red;
        case '102':
          return Colors.blue;
        case '103':
          return Colors.green;
        case '201':
          return Colors.orange;
        default:
          return Colors.black;
      }
    }();

    return DecoratedBox(
        decoration: BoxDecoration(border: Border.all(color: color)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Text(session.roomName,
              style: Theme.of(context).textTheme.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  )),
        ));
  }
}
