import 'dart:async';

import 'package:drchannels/videoplayer.dart';
import 'package:flutter/material.dart';

import 'drapi.dart';

void main() => runApp(DrApp());

class DrApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DR channels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ChannelsHomePage(title: 'DR channels'),
    );
  }
}

class ChannelsHomePage extends StatefulWidget {
  ChannelsHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ChannelsHomePageState createState() => _ChannelsHomePageState();
}

class _ChannelsHomePageState extends State<ChannelsHomePage>
    with WidgetsBindingObserver {
  DrMuRepository repo = DrMuRepository();
  Future<List<Channel>> channels;
  Timer timer;

  @override
  void initState() {
    super.initState();
    channels = repo.getAllActiveDrTvChannels();

    _startRefreshTimer();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print("Current state = $state");

    if (state == AppLifecycleState.resumed) {
      _startRefreshTimer();
    } else if (state == AppLifecycleState.paused) {
      timer?.cancel();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startRefreshTimer() {
    timer = Timer.periodic(Duration(seconds: 30), (Timer t) => _refresh());
  }

  Future<List<Channel>> _refresh() async {
    print("Refreshing channels");
    setState(() {
      channels = repo.getAllActiveDrTvChannels();
    });
    return channels;
  }

  ListTile _buildListTile(Channel channel) {
    var percentage = 0;

    return ListTile(
        leading: CircleAvatar(
          backgroundImage:
          NetworkImage(channel.primaryImageUri),
          radius: 28,
        ),
        title: Text(channel.title),
        subtitle: Text(channel.subtitle),
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        onTap: () {
          playTvChannel(channel);
        });
  }

  void playTvChannel(Channel channel) async {
    var server = channel.server();
    var qualities = server.qualities;
    qualities.sort((o1, o2) => o2.kbps.compareTo(o1.kbps));
    var stream = qualities.first.streams.first.stream;
    var url = "${server.server}/$stream";

    print("Playing video from URL: $url");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoPlayerScreen(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _refresh method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        child: new RefreshIndicator(
          child: FutureBuilder<List<Channel>>(
            future: channels,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                    children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    ...snapshot.data
                        .where((it) => it.title != null)
                        .map((nowNext) => _buildListTile(nowNext))
                  ],
                ).toList());
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return CircularProgressIndicator();
            },
          ),
          onRefresh: _refresh,
        ),
      ),
    );
  }
}
