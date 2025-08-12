import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/api.dart';

import 'package:iplayground19/bloc/notification.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.bloc,
    required this.session,
  });

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
                  bloc.add(
                      NotificationBlocRemoveEvent("${session.sessionId}"));
                },
              );
            } else {
              return IconButton(
                color: Colors.red,
                icon: Icon(Icons.favorite_border),
                onPressed: () {
                  bloc.add(
                      NotificationBlocAddEvent("${session.sessionId}"));
                  final bar = SnackBar(content: Text('我們會在議程開始前通知您！'));
                  ScaffoldMessenger.of(context).showSnackBar(bar);
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
