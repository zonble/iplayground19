import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/src/session.dart';

import 'data_bloc.dart';

class SessionPage extends StatefulWidget {
  final int day;

  SessionPage({
    Key key,
    this.day,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final DataBloc bloc = BlocProvider.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("第 ${widget.day} 天"),
      ),
      child: BlocBuilder<DataBloc, DataBlocState>(
        bloc: bloc,
        builder: (context, state) {
          print(state);
          if (state is DataBlocLoadingState) {
            return Container(
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          }
          if (state is DataBlocErrorState) {
            return Container(
              child: CupertinoButton(
                child: Text('載入失敗'),
                onPressed: () {
                  bloc.dispatch(DataBlocEvent.load);
                },
              ),
            );
          }
          if (state is DataBlocLoadedState) {
            List<Section> day;
            print(widget.day);
            if (widget.day == 1) {
              day = state.day1;
            } else if (widget.day == 2) {
              day = state.day2;
            } else {
              return Container();
            }

            var widgets = <Widget>[];
            final list = SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final section = day[index];
                var items = <Widget>[];
                items.add(SafeArea(
                  top: false,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(section.title),
                  ),
                ));
                for (final session in section.sessions) {
                  var widget = new SessionCard(session: session);
                  items.add(widget);
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items);
              }, childCount: day.length),
            );
            widgets.add(list);
            return SafeArea(
              child: Scrollbar(
                child: CustomScrollView(slivers: widgets),
              ),
            );
          }
          if (state is DataBlocInitialState) {
            bloc.dispatch(DataBlocEvent.load);
          }
          return Container();
        },
      ),
    );
  }
}

class SessionCard extends StatelessWidget {
  const SessionCard({
    Key key,
    @required this.session,
  }) : super(key: key);

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Card(
          elevation: 3,
          child: Material(
            child: InkWell(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new RoomLabel(session: session),
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoomLabel extends StatelessWidget {
  const RoomLabel({
    Key key,
    @required this.session,
  }) : super(key: key);

  final Session session;

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
