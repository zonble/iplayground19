import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/favorites_page.dart';
import 'package:iplayground19/sessions_page.dart';

import 'package:iplayground19/about.dart';
import 'package:iplayground19/bloc/data_bloc.dart';

import 'bloc/notification.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DataBloc dataBloc;
  NotificationBloc notificationBloc;

  @override
  void initState() {
    super.initState();
    dataBloc = DataBloc();
    notificationBloc = NotificationBloc(dataBloc: dataBloc);
    notificationBloc.dispatch(NotificationBlocLoadEvent());
  }

  @override
  void dispose() {
    dataBloc.dispose();
    notificationBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DataBloc>(builder: (context) => dataBloc),
        BlocProvider<NotificationBloc>(builder: (context) => notificationBloc),
      ],
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
  final List<GlobalKey<NavigatorState>> keys =
      List.generate(5, (_) => GlobalKey());
  final List<ScrollController> scrollControllers =
      List.generate(5, (_) => ScrollController());
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentState = keys[currentIndex].currentState;
        await currentState.maybePop();
        return false;
      },
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule, size: 24),
              title: Text("第 1 天"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule, size: 24),
              title: Text("第 2 天"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, size: 24),
              title: Text("我的最愛"),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info, size: 24),
              title: Text("關於"),
            ),
          ],
          onTap: (index) {
            // back home only if not switching tab
            if (currentIndex == index) {
              final currentState = keys[index].currentState;
              if (currentState.canPop()) {
                currentState.popUntil((r) => r.isFirst);
              } else {
                final controller = scrollControllers[index];
                if (controller.hasClients) {
                  controller.animateTo(
                    0,
                    duration: Duration(milliseconds: 250),
                    curve: Curves.linear,
                  );
                }
              }
            }
            currentIndex = index;
          },
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(
                navigatorKey: keys[0],
                builder: (context) => SessionsPage(
                    day: 1, scrollController: scrollControllers[0]),
              );
            case 1:
              return CupertinoTabView(
                navigatorKey: keys[1],
                builder: (context) => SessionsPage(
                    day: 2, scrollController: scrollControllers[1]),
              );
            case 2:
              return CupertinoTabView(
                navigatorKey: keys[2],
                builder: (context) => FavoritePage(
                  scrollController: scrollControllers[2],
                ),
              );
            case 3:
              return CupertinoTabView(
                navigatorKey: keys[3],
                builder: (context) => AboutPage(
                  scrollController: scrollControllers[3],
                ),
              );

            default:
              return CupertinoTabView(
                  navigatorKey: keys[4],
                  builder: (context) =>
                      CupertinoPageScaffold(child: Container()));
          }
        },
      ),
    );
  }
}
