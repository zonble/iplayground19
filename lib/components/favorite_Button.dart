import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/api.dart';

import 'package:iplayground19/bloc/notification.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    Key key,
    @required this.bloc,
    @required this.session,
  }) : super(key: key);

  final NotificationBloc bloc;
  final Session session;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationBlocState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is NotificationBlocLoadedState) {
            if (state.has("${session.sessionId}")) {
              return IconButton(
                color: Colors.red,
                icon: Icon(Icons.favorite),
                onPressed: () {
                  bloc.dispatch(
                      NotificationBlocRemoveEvent("${session.sessionId}"));
                },
              );
            } else {
              return IconButton(
                color: Colors.red,
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  bloc.dispatch(
                      NotificationBlocAddEvent("${session.sessionId}"));
                  final bar = SnackBar(content: Text('我們會在議程開始前通知您！'));
                  Scaffold.of(context).showSnackBar(bar);
                },
              );
            }
          }
          return IconButton(
            color: Colors.grey,
            icon: Icon(Icons.favorite_border),
            onPressed: () {},
          );
        });
  }
}
