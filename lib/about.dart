import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/src/sponsor.dart';

import 'data_bloc.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<Widget> makeSponsorGrid(DataBlocState state) {
    if (state is DataBlocLoadingState) {
      return [SliverToBoxAdapter(child: CupertinoActivityIndicator())];
    }
    if (state is DataBlocErrorState) {
      return [SliverToBoxAdapter(child: Text('資料載入失敗'))];
    }

    if (state is DataBlocLoadedState) {
      return <Widget>[
        SliverToBoxAdapter(child: SponsorTitle(text: '鑽石贊助')),
        SponsorGrid(sponsors: state.sponsors.diamond),
        SliverToBoxAdapter(child: SponsorTitle(text: '黃金贊助')),
        SponsorGrid(sponsors: state.sponsors.gold),
        SliverToBoxAdapter(child: SponsorTitle(text: '白銀贊助')),
        SponsorGrid(sponsors: state.sponsors.silver),
        SliverToBoxAdapter(child: SponsorTitle(text: '青銅贊助')),
        SponsorGrid(sponsors: state.sponsors.bronze),
      ];
    }

    return [SliverToBoxAdapter(child: Container())];
  }

  @override
  Widget build(BuildContext context) {
    final venueWidgets = <Widget>[
      AboutSectionTitle(text: 'Venue 場地'),
      Text('國立臺灣大學博雅教學館'),
    ];
    final venueSection =
        SliverList(delegate: SliverChildListDelegate(venueWidgets));

    final aboutWidgets = <Widget>[
      AboutSectionTitle(text: 'About 關於我們'),
      Text(
          '2017年9月，一群到東京參加 iOSDC 的工程師們，在看到國外蓬勃活躍的程式力，熱血自此被點燃，決心舉辦一場兼具廣深度又有趣的 iOS 研討會。'),
      SizedBox(height: 5),
      Text('2018年10月，有實戰技巧、初心者攻略、hard core 議題以及各式八卦政治學的 iPlaygrouond 華麗登場。'),
      SizedBox(height: 5),
      Text('2019年，iPlayground 誠摯召喚各位鍵盤好手一起來燃燒熱血，讓議程更多元、更有料！')
    ];
    final aboutSection =
        SliverList(delegate: SliverChildListDelegate(aboutWidgets));

    final sponsorTitle = SliverList(
        delegate:
            SliverChildListDelegate([AboutSectionTitle(text: 'Sponsors 贊助')]));
    DataBloc bloc = BlocProvider.of(context);
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text('關於')),
        child: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 640),
          child: BlocBuilder<DataBloc, DataBlocState>(
            bloc: bloc,
            builder: (context, state) {
              var slivers = <Widget>[];
              slivers.addAll([venueSection, aboutSection, sponsorTitle]);
              slivers.addAll(makeSponsorGrid(state));
              return CustomScrollView(slivers: slivers);
            },
          ),
        ))));
  }
}

class SponsorTitle extends StatelessWidget {
  const SponsorTitle({
    Key key,
    @required this.text,
  }) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.title);
  }
}

class SponsorGrid extends StatelessWidget {
  const SponsorGrid({
    Key key,
    @required this.sponsors,
  }) : super(key: key);

  final List<Sponsor> sponsors;

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

class AboutSectionTitle extends StatelessWidget {
  final String text;

  const AboutSectionTitle({Key key, this.text}) : super(key: key);

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
