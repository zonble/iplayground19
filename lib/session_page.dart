import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    this.padding: const EdgeInsets.all(16.0),
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
    NotificationBloc bloc = BlocProvider.of(context);

    var widgets = <Widget>[
      SizedBox(height: MediaQuery.of(context).padding.top),
      SizedBox(height: MediaQuery.of(context).padding.top),
      SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(children: <Widget>[RoomLabel(session: widget.session)]),
      ),
    ];

    final title = [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                widget.session.title,
                locale: Locale('zh', 'TW'),
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10),
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
    final main = [
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Text(
          widget.session.presenter,
          locale: Locale('zh', 'TW'),
          style: TextStyle(fontSize: 20.0),
        ),
      ),
      SizedBox(height: 5),
      Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Text(
          '第 ${widget.session.conferenceDay} 天  ${widget.session.startTime} - ${widget.session.endTime}',
          locale: Locale('zh', 'TW'),
        ),
      ),
      SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: OurMarkdown(
          data: text,
          onTapLink: (link) => launch(link),
        ),
      ),
      SizedBox(height: 30),
    ];

    widgets.addAll(title);

    if (widget.program.reviewTags.isNotEmpty) {
      var textSpans =
          widget.program.reviewTags.map((x) => TextSpan(text: x)).toList();
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: Text.rich(TextSpan(children: textSpans)),
      ));
    }

    widgets.addAll(main);

    if (widget.program != null) {
      widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Text("關於講者", style: TextStyle(fontSize: 20))));
      widgets.add(Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Divider(color: Colors.grey)));

      for (final speaker in widget.program.speakers) {
        widgets.addAll([
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              speaker.name,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: OurMarkdown(
              data: speaker.biography,
              onTapLink: (link) => launch(link),
            ),
          )
        ]);
      }
    }
    widgets.add(SizedBox(height: 50));
    widgets.add(SizedBox(height: MediaQuery.of(context).padding.bottom));

    var body = CustomScrollView(
      slivers: [
        SliverList(delegate: SliverChildListDelegate(widgets)),
      ],
    );

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(),
      child: Scaffold(
        body: Scrollbar(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640.0),
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
