import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:iplayground19/api/api.dart';
import 'package:iplayground19/bloc/notification.dart';
import 'package:iplayground19/components/favorite_Button.dart';
import 'package:iplayground19/components/room_label.dart';
import 'package:url_launcher/url_launcher.dart';

class OurMarkdown extends MarkdownWidget {
  final EdgeInsets padding;

  /// Creates a scrolling widget that parses and displays Markdown.
  const OurMarkdown({
    Key key,
    String data,
    MarkdownStyleSheet styleSheet,
    SyntaxHighlighter syntaxHighlighter,
    MarkdownTapLinkCallback onTapLink,
    Directory imageDirectory,
    this.padding: const EdgeInsets.all(16),
  }) : super(
          key: key,
          data: data,
          styleSheet: styleSheet,
          syntaxHighlighter: syntaxHighlighter,
          onTapLink: onTapLink,
          imageDirectory: imageDirectory,
        );

  @override
  Widget build(BuildContext context, List<Widget> children) {
    return Column(children: children);
  }
}

class SessionPage extends StatefulWidget {
  final Session session;
  final Program program;

  SessionPage({
    Key key,
    this.session,
    this.program,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    var text = widget.session.description;
    if (text.contains('<p>') || text.contains('<h4>')) {
      text = html2md.convert(text);
    }
    final urlPattern =
        r"(https?|ftp)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:,.;]*)?";
    final regex = new RegExp(urlPattern, caseSensitive: false);
    final matches = regex.allMatches(text);
    final links = matches.map((x) => text.substring(x.start, x.end));
    for (final link in links) {
      text = text.replaceAll(link, '[$link]($link)');
    }
    NotificationBloc bloc = BlocProvider.of(context);

    var widgets = <Widget>[
      SizedBox(height: MediaQuery.of(context).padding.top),
      SizedBox(height: 70),
      SizedBox(height: 20),
      Padding(
        padding:
            const EdgeInsets.only(left: 20, top: 8, bottom: 8.0, right: 8.0),
        child: Row(children: <Widget>[RoomLabel(session: widget.session)]),
      ),
    ];

    final title = [
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.session.title,
                locale: Locale('zh', 'TW'),
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 20),
            ClipOval(
              child: Material(
                  child: InkWell(
                      child:
                          FavoriteButton(bloc: bloc, session: widget.session))),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
    ];
    final metadata = [
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Text(
          widget.session.presenter,
          locale: Locale('zh', 'TW'),
          style: TextStyle(fontSize: 20),
        ),
      ),
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Text(
          '第 ${widget.session.conferenceDay} 天  ${widget.session.startTime} - ${widget.session.endTime}',
          locale: Locale('zh', 'TW'),
        ),
      ),
      SizedBox(height: 20),
    ];

    widgets.addAll(title);

    if (widget.program.reviewTags.contains('workshop')) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Text('workshop'),
      ));
    }

    widgets.addAll(metadata);
    final textBody = [
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: OurMarkdown(
          data: text.trim(),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
              p: Theme.of(context).textTheme.body1.copyWith(fontSize: 17)),
          onTapLink: (link) => launch(
            link,
            forceSafariVC: false,
          ),
        ),
      ),
      SizedBox(height: 30),
    ];

    widgets.addAll(textBody);

    if (widget.program != null) {
      widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Text("關於講者", style: TextStyle(fontSize: 20))));

      widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Divider(color: Colors.grey)));

      if (imageName != null) {
        final image = Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 200,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipOval(
                  child: Image.asset(imageName),
                ),
              ),
            ));
        widgets.add(image);
      }

      for (final speaker in widget.program.speakers) {
        widgets.addAll([
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              speaker.name,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: OurMarkdown(
              data: speaker.biography.trim(),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                      p: Theme.of(context)
                          .textTheme
                          .body1
                          .copyWith(fontSize: 17)),
              onTapLink: (link) => launch(link),
            ),
          )
        ]);
      }

      final String twitter = widget.program.customFields['SNS'];
      if (twitter != null && twitter.isNotEmpty) {
        final row = Row(
          children: <Widget>[
            Text('SNS:'),
            SizedBox(width: 10),
            Flexible(
              child: FlatButton(
                  child: Text(twitter,
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () => launch(
                        twitter,
                        forceSafariVC: false,
                      )),
            ),
          ],
        );
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: row,
        ));
      }
    }
    widgets.add(SizedBox(height: 50));
    widgets.add(SizedBox(height: MediaQuery.of(context).padding.bottom));
    widgets = widgets
        .map((x) => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 680),
                child: Container(width: double.infinity, child: x),
              ),
            ))
        .toList();

    var body = CustomScrollView(
      slivers: [
        SliverList(delegate: SliverChildListDelegate(widgets)),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Scaffold(
        body: Scrollbar(
          child: body,
        ),
      ),
    );
  }

  String imageName;

  detectHasImage() async {
    var name = 'images/a_' +
        widget.session.presenter
            .replaceAll(' ', '_')
            .replaceAll('-', '_')
            .replaceAll(',', '')
            .toLowerCase() +
        '.png';
    try {
      await rootBundle.load(name);
      setState(() => imageName = name);
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 250), () => detectHasImage());
  }
}
