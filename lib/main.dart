import 'package:flutter/material.dart';
import 'package:iplayground19/session_page.dart';

import 'data_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var bloc = DataBloc();

  @override
  void dispose() {
    super.dispose();
    bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<DataBloc>(builder: (context) => bloc)],
      child: MaterialApp(
        title: 'iPlayground 19',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      children: <Widget>[
        Offstage(offstage: 0 != _index, child: SessionPage(day: 1)),
        Offstage(offstage: 1 != _index, child: SessionPage(day: 2)),
      ],
    );

    final bar = BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_day),
          title: Text("第 1 天"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_view_day),
          title: Text("第 2 天"),
        ),
      ],
      currentIndex: _index,
      onTap: (index) => setState(() => _index = index),
    );

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(child: stack),
            bar,
          ],
        ),
      ),
    );
  }
}
