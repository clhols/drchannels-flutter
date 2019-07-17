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

class _ChannelsHomePageState extends State<ChannelsHomePage> {
  DrMuRepository repo = DrMuRepository();
  Future<List<MuNowNext>> channels;

  @override
  void initState() {
    super.initState();
    channels = repo.getScheduleNowNext();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //_counter++;
    });
  }

  void playTvChannel(MuNowNext nowNext) async {
    var channels = await repo.getAllActiveDrTvChannels();

    var server =
        channels.firstWhere((it) => it.slug == nowNext.channelSlug).server();
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
    // by the _incrementCounter method above.
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
        child: FutureBuilder<List<MuNowNext>>(
          future: channels,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                  children: ListTile.divideTiles(
                context: context,
                tiles: [
                  ...snapshot.data.where((it) => it.now != null).map(
                      (nowNext) => ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                                nowNext.now.programCard.primaryImageUri),
                            radius: 28,
                          ),
                          title: Text(nowNext.now.title),
                          subtitle: Text(nowNext.now.description),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 24),
                          onTap: () {
                            playTvChannel(nowNext);
                          }))
                ],
              ).toList());
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
