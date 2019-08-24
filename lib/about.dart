import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iplayground19/api/src/sponsor.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data_bloc.dart';

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
                [AboutSectionTitle(text: 'Sponsors 贊助')])));
    final coTitle = SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
                [AboutSectionTitle(text: 'Co-organizers 合作夥伴')])));
    final coGrid = makeCoOrganizersGrid();

    final staffTitle = SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: SliverList(
            delegate: SliverChildListDelegate(
                [AboutSectionTitle(text: 'Staffs 工作人員')])));
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

  Widget makeVenue() {
    final venueWidgets = <Widget>[
      AboutSectionTitle(text: 'Venue 場地'),
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

  Widget makeAboutUs() {
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
    return SliverPadding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        sliver: aboutSection);
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
        SliverToBoxAdapter(child: SponsorTitle(text: '鑽石贊助')),
        SponsorGrid(sponsors: state.sponsors.diamond),
        SliverToBoxAdapter(child: SponsorTitle(text: '黃金贊助')),
        SponsorGrid(sponsors: state.sponsors.gold),
        SliverToBoxAdapter(child: SponsorTitle(text: '白銀贊助')),
        SponsorGrid(sponsors: state.sponsors.silver),
        SliverToBoxAdapter(child: SponsorTitle(text: '青銅贊助')),
        SponsorGrid(sponsors: state.sponsors.bronze),
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
    final List<List<String>> data = [
      [
        'Hokila',
        'images/s_hokila.jpg',
        'Father/ Trello Lover',
        'https://twitter.com/hokilaJ',
      ],
      [
        'Dada',
        'images/s_dada.jpg',
        'iOS Developer @ KKBOX',
        'https://twitter.com/nalydadad',
      ],
      [
        'Superbil',
        'images/s_superbil.png',
        'Software Freelancer',
        'https://twitter.com/superbil',
      ],
      [
        '大軍',
        'images/s_dj.jpg',
        '程式、平面、動態設計都很有興趣，喜歡交朋友歡迎認識。',
        'https://www.facebook.com/profile.php?id=100000194796912',
      ],
      [
        '13 一三',
        'images/s_13.jpg',
        'I write cool apps for living.',
        'https://twitter.com/ethanhuang13',
      ],
      [
        '陳涵宇',
        'images/s_hy.png',
        '我後面有一隻毛毛蟲。',
        'https://www.facebook.com/hanyu.chen.518',
      ],
      [
        'Hao Lee',
        'images/s_haolee.jpg',
        'macOS Developer',
        'https://twitter.com/twhaolee',
      ],
      [
        'Luke Wu',
        'images/s_lukewu.jpg',
        'iOS Instructor at AppWorks School',
        'https://www.facebook.com/mvp0627',
      ],
      [
        'Will Chen',
        'images/s_willchen.jpeg',
        'iOS Developer',
        'https://twitter.com/willchen00'
      ],
      [
        'Toby Hsu',
        'images/s_tobyhsu.jpg',
        'tvOS Dev @ CATCHPLAY',
        'https://twitter.com/HsuToby',
      ],
      [
        'BigRoot',
        'images/s_bigroot.jpeg',
        'KKBOX iOS Developer',
        'https://twitter.com/BigRootHsu',
      ],
      [
        'Chung',
        'images/s_chung.png',
        'iOS Evangelist / Consultant / Trainer /Developer',
        'https://twitter.com/ChungPlusDev'
      ],
      [
        'Tank',
        'images/s_tank.jpg',
        'iOS Developer at KKday',
        'https://twitter.com/tank1005',
      ],
      [
        '鄭雅方',
        'images/s_yf.png',
        'APP Girls 創辦人',
        'https://www.facebook.com/groups/1260405513988915/',
      ],
      [
        'Steve Sun',
        'images/s_stevensun.jpg',
        'iOS Developer @ Hootsuite',
        'https://fb.me/steve.sun.125'
      ],
      [
        'MarkFly',
        'images/s_markfly.png',
        'iOS developer learning Android',
        'https://www.facebook.com/mark33699',
      ],
      [
        'JimmyLiao',
        'images/s_jimmyliao.jpeg',
        'Jimmyliao',
        'https://twitter.com/jimmyliao',
      ],
      [
        'Dan',
        'images/s_dan.jpg',
        'iOS Developer @Readmoo, Monster Hunter, Pokémon Master.',
        'https://twitter.com/phy1988',
      ],
      [
        'Mike',
        'images/s_mike.jpeg',
        'Rookie iOS Developer',
        'https://www.facebook.com/mikechouo',
      ],
      [
        'Bob Chang',
        'images/s_bobchang.jpg',
        'iOS dev chicken',
        'https://twitter.com/bob910078',
      ],
      [
        'Joe Chen',
        'images/s_joechen.jpg',
        '我程式不會動，我不知道為什麼；我程式會動，我不知道為什麼',
        'https://twitter.com/joe_trash_talk',
      ],
      [
        'Kennedy',
        'images/s_kennedy.png',
        'iOS Developer ',
        null,
      ],
      [
        'Johnny Sung',
        'images/s_johnnysung.jpg',
        'iOS / Android Developer',
        'https://fb.me/j796160836',
      ],
      [
        'OOBE',
        'images/s_oobe.png',
        'Producer',
        'https://twitter.com/OOBE',
      ],
      [
        'Yoda',
        'images/s_yoda.jpg',
        'Jedi / Designer / Developer',
        'https://www.facebook.com/YongSaingWang'
      ],
      [
        'Gerry',
        'images/s_gerry.png',
        '佛心軟體工程師',
        'https://twitter.com/gerry73740659',
      ],
      [
        'TaiHsin',
        'images/s_taihsin.jpg',
        'iOS Developer @ KKBOX',
        'https://www.facebook.com/peter.lee.752487'
      ],
      [
        'Pofat',
        'images/s_pofat.jpg',
        '本鵝用翅膀寫 code',
        'https://twitter.com/PofatTseng',
      ],
      [
        'Cindy',
        'images/s_cindy.jpeg',
        'iOS Developer @H2Sync',
        'https://www.facebook.com/hsin.chen.10',
      ],
      [
        'Jeffrey Wang',
        'images/s_jefferywang.jpg',
        'Tech Lover / PM',
        'https://www.facebook.com/jeffrey.wang.505',
      ],
      [
        'Allen Lai',
        'images/s_allenlai.jpg',
        'iOS Developer',
        'https://twitter.com/AllenEzailLai',
      ],
      [
        '啊嘶',
        'images/s_as.jpg',
        '程式碼行數減少，體重卻默默上升',
        'https://www.facebook.com/profile.php?id=100000061272837',
      ],
      [
        'Mack Liu',
        'images/s_mackliu.jpg',
        'iOS / .NET Developer',
        'https://www.facebook.com/bazhe1106'
      ],
      [
        'Lim Yang',
        'images/s_limyang.jpg',
        'system engineer at Thinking Software',
        'https://www.facebook.com/arawn.yang',
      ],
      [
        'Alice',
        'images/s_alice.jpg',
        'iOS developer @H2sync',
        'https://www.facebook.com/profile.php?id=100002422822162',
      ],
      [
        'Annie Li',
        'images/s_annieli.jpg',
        'iOS Developer @ KKBOX',
        'https://www.facebook.com/profile.php?id=1824210769',
      ],
      [
        'Roger',
        'images/s_roger.jpg',
        'iOS Developer',
        'https://twitter.com/roger_fanfan',
      ],
      [
        'Crystal',
        'images/s_crystal.jpg',
        'iOS Developer',
        'https://www.facebook.com/liu.crystal.9',
      ]
    ];

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

  makeCoOrganizersGrid() {
    final List<List<String>> data = [
      [
        'images/co_aatp.png',
        'https://aatp.com.tw',
      ],
      [
        'images/co_cocoaheads_tw.png',
        'https://www.facebook.com/groups/cocoaheads.taipei/'
      ],
      [
        'images/co_ios_taipei.png',
        'https://www.facebook.com/groups/ios.taipei/',
      ],
      [
        'images/co_swift_taipei.png',
        'https://www.meetup.com/Swift-Taipei-User-Group/',
      ],
      [
        'images/co_app_girls.png',
        'https://www.facebook.com/groups/1260405513988915/',
      ],
    ];
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
