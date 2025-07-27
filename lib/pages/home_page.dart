import 'dart:convert';
import 'dart:ui';

import 'package:ai_voice_assistant_sound_player_app/pages/feedback2.dart';
import 'package:ai_voice_assistant_sound_player_app/ultils/ai_ultils.dart';
import 'package:alan_voice/alan_voice.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:string_to_color/string_to_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:velocity_x/velocity_x.dart';
//import 'package:assets_audio_player/assets_audio_player.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Radio> _radios;
  Radio _selectedRadio;
  Color _selectedColor;
  bool _isPlaying = false;
  final sugg = [
    "Play",
    "Stop",
    "Play rock music",
    "Play 107 FM",
    "Play next",
    "Play 104 FM",
    "Pause",
    "Play previous",
    "Play pop music"
  ];

  AudioPlayer player = AudioPlayer();
  // final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    setupAlan();
//    fetchRadios();

    _loadRadios();
    //  playMusic(0);
    // colorFromHex("0xffa11431");
    player.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.playing) {
        _isPlaying = true;
      } else {
        _isPlaying = false;
      }
      setState(() {});
    });
  }

  Future<void> _loadRadios() async {
    String jsonString = await rootBundle.loadString('assets/radio.json');
    Map<String, dynamic> jsonData = jsonDecode(jsonString);

    _radios = new List<Radio>();

    for (var radio in jsonData['radio']) {
      _radios.add(new Radio.fromJson(radio));
    }

    _selectedRadio = _radios[0];
    _selectedColor = Color(int.tryParse(_selectedRadio.color));
    setState(() {});
  }

  /*void stopMusic() {
    // Get the current audio player.
    //  AudioPlayer player = AudioPlayer.global as AudioPlayer;

    // Stop the player.
    player.stop();
    setState(() {});
  }*/

  /*void playMusic(int id) {
    Radio radio = _radios.firstWhere((r) => r.id == id);

    if (radio != null) {
      assetsAudioPlayer.open(
        Audio('assets/Ya Adheeman.mp3'),
      );
      assetsAudioPlayer.play();
    }
  }*/

  setupAlan() {
    AlanVoice.addButton(
        "c5cc247b7e393ff1f9e04d887773a1a72e956eca572e1d8b807a3e2338fdd0dc/stage",
        buttonAlign: AlanVoice.BUTTON_ALIGN_RIGHT);
    AlanVoice.callbacks.add((command) => _handleCommand(command.data));
  }

  _handleCommand(Map<String, dynamic> response) {
    switch (response["command"]) {
      case "play":
        playMusic(_selectedRadio.id);
        break;

      case "play_channel":
        final id = response["id"];
        // _audioPlayer.pause();
        Radio newRadio = _radios.firstWhere((element) => element.id == id);
        _radios.remove(newRadio);
        _radios.insert(0, newRadio);
        playMusic(newRadio.id);
        break;

      case "stop":
        player.stop();
        break;
      case "next":
        final index = _selectedRadio.id;
        Radio newRadio;
        if (index + 1 > _radios.length) {
          newRadio = _radios.firstWhere((element) => element.id == 1);
          _radios.remove(newRadio);
          _radios.insert(0, newRadio);
        } else {
          newRadio = _radios.firstWhere((element) => element.id == index + 1);
          _radios.remove(newRadio);
          _radios.insert(0, newRadio);
        }
        playMusic(newRadio.id);
        break;

      case "prev":
        final index = _selectedRadio.id;
        Radio newRadio;
        if (index - 1 <= 0) {
          newRadio = _radios.firstWhere((element) => element.id == 1);
          _radios.remove(newRadio);
          _radios.insert(0, newRadio);
        } else {
          newRadio = _radios.firstWhere((element) => element.id == index - 1);
          _radios.remove(newRadio);
          _radios.insert(0, newRadio);
        }
        playMusic(newRadio.id);
        break;
      default:
        print("Command was ${response["command"]}");
        break;
    }
  }
/*
  Future fetchRadios() async {
    String radioJson = await rootBundle.loadString('assets/radio.json');
    _radios = await jsonDecode(radioJson);

    _selectedRadio = _radios[0];
    _selectedColor = ColorUtils.stringToColor(_selectedRadio.color);
    print(_radios);
    setState(() {});
  }*/

  /*_playMusic(String url) {
    player.play("assets/s1.mp3" as Source);
    _selectedRadio = _radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }*/

  Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('', ''));
    final int color = int.parse(buffer.toString(), radix: 16);
    return Color(color);
  }

  void playMusic(int id) {
    Radio radio = _radios.firstWhere((r) => r.id == id);

    if (radio != null) {
      //AudioPlayer player = AudioPlayer();
      Source audioUrl;
      audioUrl = UrlSource(radio.url);
      player.play(audioUrl);
    }
/*
    _selectedRadio = _radios.firstWhere((element) => element.url == url);
    player.play(url as Source);*/
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: _selectedColor,
          child: _radios != null
              ? [
                  100.heightBox,
                  "All Channels".text.xl.white.semiBold.make().px16(),
                  20.heightBox,
                  ListView(
                    padding: Vx.m0,
                    shrinkWrap: true,
                    children: _radios
                        .map((e) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(e.icon),
                              ),
                              title: "${e.name} FM".text.white.make(),
                              subtitle: e.tagline.text.white.make(),
                            ))
                        .toList(),
                  ).expand()
                ].vStack(crossAlignment: CrossAxisAlignment.start)
              : const Offstage(),
        ),
      ),
      body: Stack(
        children: [
          VxAnimatedBox()
              .size(context.screenWidth, context.screenHeight)
              .withGradient(
                LinearGradient(
                  colors: [
                    AIColors.primaryColor2,
                    _selectedColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
              .make(),
          [
            AppBar(
              title: "Harmonic HUB".text.xl4.bold.white.make().shimmer(
                  primaryColor: Vx.purple300, secondaryColor: Colors.white),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            "Start with - Hey Alan 👇".text.italic.semiBold.white.make(),
            10.heightBox,
            VxSwiper.builder(
              itemCount: sugg.length,
              height: 50.0,
              viewportFraction: 0.35,
              autoPlay: true,
              autoPlayAnimationDuration: 3.seconds,
              autoPlayCurve: Curves.linear,
              enableInfiniteScroll: true,
              itemBuilder: (context, index) {
                final s = sugg[index];
                return Chip(
                  label: s.text.make(),
                  backgroundColor: Vx.randomColor,
                );
              },
            )
          ].vStack(alignment: MainAxisAlignment.start),
          30.heightBox,
          _radios != null
              ? VxSwiper.builder(
                  itemCount: _radios.length,
                  aspectRatio: context.mdWindowSize == MobileDeviceSize.small
                      ? 1.0
                      : context.mdWindowSize == MobileDeviceSize.medium
                          ? 2.0
                          : 3.0,
                  enlargeCenterPage: true,
                  onPageChanged: (index) {
                    _selectedRadio = _radios[index];
                    _selectedColor = Color(int.tryParse(_selectedRadio.color));

                    setState(() {});
                  },
                  itemBuilder: (context, index) {
                    final rad = _radios[index];
                    //    _selectedColor = colorFromHex(rad.color);
                    return VxBox(
                            child: ZStack(
                      [
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: VxBox(
                            child:
                                rad.category.text.white.uppercase.make().px16(),
                          )
                              .height(40)
                              .black
                              .alignCenter
                              .withRounded(value: 10.0)
                              .make(),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VStack(
                            [
                              rad.name.text.xl3.white.bold.make(),
                              5.heightBox,
                              rad.tagline.text.sm.white.semiBold.make(),
                            ],
                            crossAlignment: CrossAxisAlignment.center,
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: [
                              Icon(
                                CupertinoIcons.play_circle,
                                color: Colors.white,
                              ),
                              10.heightBox,
                              "Double tap to play".text.gray300.make(),
                            ].vStack())
                      ],
                    ))
                        .clip(Clip.antiAlias)
                        .bgImage(
                          DecorationImage(
                              image: NetworkImage(rad.image),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.darken)),
                        )
                        .border(color: Colors.black, width: 5.0)
                        .withRounded(value: 60.0)
                        .make()
                        .onInkDoubleTap(() {
                      if (_isPlaying == true) {
                        player.pause();
                      }
                      playMusic(rad.id);
                    }).p16();
                  },
                ).centered()
              : Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: [
              if (_isPlaying)
                "Playing Now - ${_selectedRadio.name} FM"
                    .text
                    .white
                    .makeCentered(),
              Icon(
                _isPlaying
                    ? CupertinoIcons.stop_circle
                    : CupertinoIcons.play_circle,
                color: Colors.white,
                size: 50.0,
              ).onInkTap(() {
                if (_isPlaying) {
                  player.pause();
                } else {
                  playMusic(_selectedRadio.id);
                }
              }),
            ].vStack(),
          ).pOnly(bottom: context.percentHeight * 12)
        ],
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}

class Radio {
  final int id;
  final String name;
  final String tagline;
  final String color;
  final String desc;
  final String url;
  final String icon;
  final String image;
  final String lang;
  final String category;
  final bool disliked;
  final int order;

  Radio({
    this.id,
    this.name,
    this.tagline,
    this.color,
    this.desc,
    this.url,
    this.icon,
    this.image,
    this.lang,
    this.category,
    this.disliked,
    this.order,
  });

  factory Radio.fromJson(Map<String, dynamic> json) {
    return new Radio(
      id: json['id'],
      name: json['name'],
      tagline: json['tagline'],
      color: json['color'],
      desc: json['desc'],
      url: json['url'],
      icon: json['icon'],
      image: json['image'],
      lang: json['lang'],
      category: json['category'],
      disliked: json['disliked'],
      order: json['order'],
    );
  }
}
