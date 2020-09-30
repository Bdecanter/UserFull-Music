import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'music.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Usefull Music'),
      debugShowCheckedModeBanner: false,
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
  AudioPlayer audioPlugin;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Duration position = Duration(seconds: 0);
  Duration duree = Duration(seconds: 0);
  PlayerState statut = PlayerState.stoped;
  int index = 0;

  List<Music> maListeMusic = [
    Music("Theme One", "Benoit", "assets/cover1.jpg",
        "https://codabee.com/wp-content/uploads/2018/06/un.mp3"),
    Music("Theme Two", "Benoit", "assets/cover2.jpg",
        "https://codabee.com/wp-content/uploads/2018/06/deux.mp3")
  ];

  Music actualMusic;

  @override
  void initState() {
    super.initState();
    actualMusic = maListeMusic[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    double length = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
        ),
        backgroundColor: Colors.grey[800],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Card(
                child: Image.asset(
                  actualMusic.imagePath,
                  width: length / 1.3,
                  height: length / 1.3,
                  fit: BoxFit.cover,
                ),
                elevation: 15,
              ),
              textStyled(actualMusic.titre, 1.5),
              textStyled(actualMusic.artiste, 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  bouton(Icons.fast_rewind, 30, ActionMusic.rewind),
                  bouton(
                      (statut == PlayerState.playing)
                          ? Icons.pause
                          : Icons.play_arrow,
                      50,
                      (statut == PlayerState.playing)
                          ? ActionMusic.pause
                          : ActionMusic.play),
                  bouton(Icons.fast_forward, 30, ActionMusic.forward),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  textStyled(fromDuration(position), 0.8),
                  textStyled(fromDuration(duree), 0.8),
                ],
              ),
              Slider(
                  value: position.inSeconds.toDouble(),
                  min: 0.0,
                  max: duree.inSeconds.toDouble(),
                  inactiveColor: Colors.white,
                  activeColor: Colors.red,
                  onChanged: (double value) {
                    setState(() {
                      audioPlugin.seek(value);
                    });
                  }),
            ],
          ),
        ));
  }

  Text textStyled(String data, double scale) {
    return Text(
      data,
      textScaleFactor: scale,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  IconButton bouton(IconData icon, double taille, ActionMusic action) {
    return IconButton(
        icon: Icon(icon),
        iconSize: taille,
        color: Colors.white,
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              print("Play");
              play();
              break;
            case ActionMusic.pause:
              print("Pause");
              pause();
              break;
            case ActionMusic.rewind:
              print("Rewind");
              rewind();
              break;
            case ActionMusic.forward:
              print("Forward");
              forward();
              break;
            default:
          }
        });
  }

  void configurationAudioPlayer() {
    audioPlugin = AudioPlayer();
    positionSub = audioPlugin.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlugin.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {
          duree = audioPlugin.duration;
        });
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stoped;
        });
      }
    }, onError: (message) {
      print('erreur: $message');
      setState(() {
        statut = PlayerState.stoped;
        duree = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlugin.play(actualMusic.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlugin.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListeMusic.length - 1) {
      index = 0;
    } else {
      index++;
    }
    actualMusic = maListeMusic[index];
    audioPlugin.stop();
    configurationAudioPlayer();
    play();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlugin.seek(0.0);
    } else {
      if (index == 0) {
        index = maListeMusic.length - 1;
      } else {
        index--;
      }
      actualMusic = maListeMusic[index];
      audioPlugin.stop();
      configurationAudioPlayer();
      play();
    }
  }

  String fromDuration(Duration duree) {
    return duree.toString().split('.').first;
  }
}

enum ActionMusic { play, pause, rewind, forward }
enum PlayerState { playing, paused, stoped }
