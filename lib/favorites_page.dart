import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:iplayground19/bloc/notification.dart';
import 'package:iplayground19/components/session_card.dart';

class FavoritePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    DataBloc dataBloc = BlocProvider.of(context);
    NotificationBloc notificationBloc = BlocProvider.of(context);

    var content = BlocBuilder<DataBloc, DataBlocState>(
      bloc: dataBloc,
      builder: (context, dataState) {
        if (dataState is DataBlocLoadingState) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('載入中，請稍候…'),
                  SizedBox(height: 20),
                  CupertinoActivityIndicator(),
                ],
              ),
            ),
          );
        }

        if (dataState is DataBlocErrorState) {
          return SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('載入時發生問題'),
                  CupertinoButton(
                    child: Text('重試'),
                    onPressed: () {
                      dataBloc.dispatch(DataBlocEvent.load);
                    },
                  ),
                ],
              ),
            ),
          );
        }

        if (dataState is DataBlocLoadedState) {
          return BlocBuilder<NotificationBloc, NotificationBlocState>(
            bloc: notificationBloc,
            builder: (context, notificationState) {
              if (notificationState is NotificationBlocLoadedState) {
                final saved = notificationState.sessions;
                if (saved.isEmpty) {
                  return SafeArea(child: Center(child: Text('您還沒有任何最愛的議程')));
                }
                final all = dataState.sessions;
                final filterd = all.keys
                    .where((x) => saved.contains(x))
                    .map((x) => all[x])
                    .cast<Session>()
                    .toList();
                filterd.sort();

                var slivers = <Widget>[];
                slivers.add(SliverToBoxAdapter(
                    child:
                        SizedBox(height: MediaQuery.of(context).padding.top)));
                slivers.add(SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final session = filterd[index];
                    final id = session.proposalId.substring(5);
                    final program = dataState.programs[id];
                    final card = SessionCard(
                      session: session,
                      program: program,
                      showDetails: true,
                    );
                    return card;
                  },
                  childCount: filterd.length,
                )));

                slivers.add(SliverToBoxAdapter(child: SizedBox(height: 30)));
                slivers.add(SliverToBoxAdapter(
                    child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom)));

                return CustomScrollView(slivers: slivers);
              }
              return Container();
            },
          );
        }

        return Container();
      },
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('我的最愛'),
      ),
      child: Scaffold(
        body: Scrollbar(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640.0),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
