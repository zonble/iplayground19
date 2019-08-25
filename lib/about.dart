import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/api/src/sponsor.dart';
import 'package:iplayground19/bloc/data_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    final logo = SliverToBoxAdapter(child: Image.asset('images/logo.png'));
    final venueSection = makeVenue();
    final aboutSection = makeAboutUs();
    final sponsorTitle = SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
                [_AboutSectionTitle(text: 'Sponsors 贊助')])));
    final coTitle = SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
                [_AboutSectionTitle(text: 'Co-organizers 合作夥伴')])));
    final coGrid = makeCoOrganizersGrid();

    final staffTitle = SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
                [_AboutSectionTitle(text: 'Staffs 工作人員')])));
    final staffGrid = makeStaffGrid();

    // --

    DataBloc bloc = BlocProvider.of(context);
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('關於')),
        child: SafeArea(
            child: Scrollbar(
          child: Center(
              child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 640),
            child: BlocBuilder<DataBloc, DataBlocState>(
              bloc: bloc,
              builder: (context, state) {
                var slivers = <Widget>[];
                slivers
                    .addAll([logo, venueSection, aboutSection, sponsorTitle]);
                slivers.addAll(makeSponsorGrid(state));
                slivers.addAll([
                  coTitle,
                  coGrid,
                  staffTitle,
                  staffGrid,
                  SliverToBoxAdapter(child: Container(height: 60.0))
                ]);
                return CustomScrollView(slivers: slivers);
              },
            ),
          )),
        )));
  }

  Widget makeAboutUs() {
    final aboutWidgets = <Widget>[
      _AboutSectionTitle(text: 'About 關於我們'),
      Text(
          '2017年9月，一群到東京參加 iOSDC 的工程師們，在看到國外蓬勃活躍的程式力，熱血自此被點燃，決心舉辦一場兼具廣深度又有趣的 iOS 研討會。'),
      SizedBox(height: 5),
      Text('2018年10月，有實戰技巧、初心者攻略、hard core 議題以及各式八卦政治學的 iPlaygrouond 華麗登場。'),
      SizedBox(height: 5),
      Text('2019年，iPlayground 誠摯召喚各位鍵盤好手一起來燃燒熱血，讓議程更多元、更有料！')
    ];
    final aboutSection =
        SliverList(delegate: SliverChildListDelegate(aboutWidgets));
    return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: aboutSection);
  }

  makeCoOrganizersGrid() {
    final data = coOrganizerData();
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = data[index];
          return LayoutBuilder(builder: (context, constraints) {
            return Container(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => launch(item[1]),
                  child: Container(),
                ),
              ),
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage(item[0]))),
            );
          });
        }, childCount: data.length),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200.0,
          crossAxisSpacing: 10.0,
        ),
      ),
    );
  }

  List<Widget> makeSponsorGrid(DataBlocState state) {
    if (state is DataBlocLoadingState) {
      return [
        SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            sliver: SliverToBoxAdapter(child: CupertinoActivityIndicator()))
      ];
    }
    if (state is DataBlocErrorState) {
      return [
        SliverPadding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            sliver: SliverToBoxAdapter(child: Text('資料載入失敗')))
      ];
    }

    if (state is DataBlocLoadedState) {
      return <Widget>[
        SliverToBoxAdapter(child: _SponsorTitle(text: '鑽石贊助')),
        _SponsorGrid(sponsors: state.sponsors.diamond),
        SliverToBoxAdapter(child: _SponsorTitle(text: '黃金贊助')),
        _SponsorGrid(sponsors: state.sponsors.gold),
        SliverToBoxAdapter(child: _SponsorTitle(text: '白銀贊助')),
        _SponsorGrid(sponsors: state.sponsors.silver),
        SliverToBoxAdapter(child: _SponsorTitle(text: '青銅贊助')),
        _SponsorGrid(sponsors: state.sponsors.bronze),
      ].map((sliver) {
        return SliverPadding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          sliver: sliver,
        );
      }).toList();
    }

    return [SliverToBoxAdapter(child: Container())];
  }

  makeStaffGrid() {
    final data = staffData();
    return SliverPadding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((context, index) {
          final item = data[index];
          return LayoutBuilder(builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    width: constraints.maxWidth,
                    height: constraints.maxWidth,
                    decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage(item[1]))),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          var link = item[3];
                          if (link != null) {
                            launch(link);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Text(item[0], style: TextStyle(fontSize: 22.0)),
                SizedBox(height: 4),
                Text(
                  item[2],
                  textAlign: TextAlign.center,
                ),
              ],
            );
          });
        }, childCount: data.length),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            childAspectRatio: 0.5,
            crossAxisSpacing: 10.0),
      ),
    );
  }

  Widget makeVenue() {
    final venueWidgets = <Widget>[
      _AboutSectionTitle(text: 'Venue 場地'),
      Row(
        children: <Widget>[
          Text('國立臺灣大學博雅教學館'),
          CupertinoButton(
            child: Text('在地圖中開啟'),
            onPressed: () {
              var url = 'https://tinyurl.com/y4h9ja9y';
              launch(url);
            },
          )
        ],
      ),
    ];
    final venueSection =
        SliverList(delegate: SliverChildListDelegate(venueWidgets));
    return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: venueSection);
  }
}

class _AboutSectionTitle extends StatelessWidget {
  final String text;

  const _AboutSectionTitle({Key key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text, style: Theme.of(context).textTheme.display1),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }
}

class _SponsorGrid extends StatelessWidget {
  final List<Sponsor> sponsors;

  const _SponsorGrid({
    Key key,
    @required this.sponsors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate((context, index) {
        final sponsor = sponsors[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(sponsor.imageUrl))),
                );
              }),
              SizedBox(height: 10),
              Text(sponsor.name),
            ],
          ),
        );
      }, childCount: sponsors.length),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        childAspectRatio: 0.7,
      ),
    );
  }
}

class _SponsorTitle extends StatelessWidget {
  final String text;

  const _SponsorTitle({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.title);
  }
}
