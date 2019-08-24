import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/sessions_page.dart';

import 'about.dart';
import 'data_bloc.dart';

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
      child: CupertinoApp(
        title: 'iPlayground 19',
        theme: CupertinoThemeData(
          primaryColor: Color.fromRGBO(80, 121, 255, 1.0),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
//        border: Border.all(color: Colors.black),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schedule,
              size: 24,
            ),
            title: Text("第 1 天"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schedule,
              size: 24,
            ),
            title: Text("第 2 天"),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.info,
              size: 24,
            ),
            title: Text("關於"),
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) => SessionsPage(day: 1));
          case 1:
            return CupertinoTabView(builder: (context) => SessionsPage(day: 2));
          case 2:
            return CupertinoTabView(builder: (context) => AboutPage());

          default:
            return CupertinoTabView(
                builder: (context) =>
                    CupertinoPageScaffold(child: Container()));
        }
      },
    );
  }
}
