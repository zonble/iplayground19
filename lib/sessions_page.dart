import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:iplayground19/components/session_card.dart';

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
                  final id = session.proposalId.substring(5);
                  final program = state.programs[id];
                  final widget = SessionCard(
                    session: session,
                    program: program,
                  );
                  items.add(widget);
                }
                return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: items);
              }, childCount: day.length),
            );

            widgets.addAll([
              SliverToBoxAdapter(
                  child: SizedBox(height: MediaQuery.of(context).padding.top)),
              list,
              SliverToBoxAdapter(child: SizedBox(height: 30)),
              SliverToBoxAdapter(
                  child:
                      SizedBox(height: MediaQuery.of(context).padding.bottom)),
            ]);
            return Scaffold(
              body: Scrollbar(
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
          constraints: BoxConstraints(maxWidth: 680),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
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
