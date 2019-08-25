import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/bloc/notification.dart';
import 'package:iplayground19/session_page.dart';
import 'package:iplayground19/components/room_label.dart';

import 'package:iplayground19/components/favorite_Button.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    Key key,
    @required this.session,
  }) : super(key: key);

  final Session session;

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Card(
                elevation: 1,
                child: buildInner(context),
              ),
            ),
          ),
        ),
      );

  Widget buildInner(BuildContext context) {
    NotificationBloc bloc = BlocProvider.of(context);
    return Material(
      child: InkWell(
        onTap: () {
          final page = SessionPage(session: session);
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (context) => page));
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      RoomLabel(session: session),
                      SizedBox(height: 10),
                      Text(session.title,
                          style: Theme.of(context).textTheme.title),
                      SizedBox(height: 5),
                      Text(session.presenter, style: TextStyle(fontSize: 17.0)),
                      SizedBox(height: 20),
                      Text('結束時間 ' + session.endTime,
                          style: Theme.of(context).textTheme.body1),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                FavoriteButton(bloc: bloc, session: session)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
