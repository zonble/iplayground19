import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/src/session.dart';
import 'package:iplayground19/program_page.dart';
import 'package:iplayground19/room_label.dart';

import 'data_bloc.dart';

class SessionsPage extends StatefulWidget {
  final int day;

  SessionsPage({
    Key key,
    this.day,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  Widget build(BuildContext context) {
    final DataBloc bloc = BlocProvider.of(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("第 ${widget.day} 天 - 09/2${widget.day}"),
      ),
      child: BlocBuilder<DataBloc, DataBlocState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is DataBlocLoadingState) {
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

          if (state is DataBlocErrorState) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('載入時發生問題'),
                    CupertinoButton(
                      child: Text('重試'),
                      onPressed: () {
                        bloc.dispatch(DataBlocEvent.load);
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DataBlocLoadedState) {
            List<Section> day;
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
                items.add(TimeSectionLabel(section: section));
                for (final session in section.sessions) {
                  final widget = SessionCard(session: session);
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

class TimeSectionLabel extends StatelessWidget {
  const TimeSectionLabel({
    Key key,
    @required this.section,
  }) : super(key: key);

  final Section section;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
                width: double.infinity,
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.display1,
                )),
          ),
        ),
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
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 640),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Card(
              elevation: 3,
              child: Material(
                child: InkWell(
                  onTap: () {
                    final page = ProgramPage(session: session);
                    Navigator.of(context)
                        .push(CupertinoPageRoute(builder: (context) => page));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          RoomLabel(session: session),
                          SizedBox(height: 10),
                          Text(session.title,
                              style: Theme.of(context).textTheme.title),
                          SizedBox(height: 5),
                          Text(session.presenter,
                              style: TextStyle(fontSize: 17.0)),
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
        ),
      ),
    );
  }
}
