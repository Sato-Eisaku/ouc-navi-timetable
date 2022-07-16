import 'dart:html';
import 'package:bus_jr_timetable/my_icons_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// json関係
// import 'package:json_serializable/json_serializable.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'timetable_json.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Bus & JR TimeTable'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Color backgroundColor = Color.fromARGB(255, 5, 0, 13);
  // json関係
  late SampleModel _samples;
  late Map cardData;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _jsonFileLoad().then((value) {
      setState(() {
        _samples = value;
        print(_samples.textTraffic);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    DateTime _now = DateTime.now();
    DateFormat dateFormat = DateFormat('mm:ss');
    String timeString = dateFormat.format(_now);
    return Scaffold(
      // bodyの背景色を設定
      backgroundColor: backgroundColor,
      // appbarの実装
      appBar: AppBar(
        // 左側の戻るボタン
        leading: IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minHeight: 24.0,
            minWidth: 24.0,
          ),
          iconSize: 28,
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
          },
        ),
        // タイトル
        title: Text(widget.title),
        // タイトルを左よせに
        centerTitle: false,
        // 右側のメニューボタン
        actions: <Widget>[
          IconButton(
            iconSize: 28,
            icon: Icon(Icons.menu),
            onPressed: () {
            },
          ),
        ],
        // appbarの境界線を無くす
        elevation: 0,
        // appbarの背景色をbodyの背景色と同じに
        backgroundColor: backgroundColor,
        // appbarの高さを調整
        toolbarHeight: size.height * 0.07,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (int i=0; i<4; i++)...{
              TimeTableCard(
                size: size,
                now: _now,
              )
            }
          ]
        )
      ),
    );
  }

  // timetable.jsonの読み込み
  // 非同期処理らしい
  Future<dynamic> _jsonFileLoad() async {
    String path = 'json/timetable.json';
    String jsonString;
    // 例外処理
    try {
      jsonString = await rootBundle.loadString(path);
    } catch(e) {
      print(e);
      exit(0);
    }

    return SampleModel.fromJson(jsonDecode(jsonString));
  }
}

class TimeTableCard extends StatelessWidget{
  TimeTableCard({Key? key, required this.now, required this.size}) : super(key: key);
  Size size;
  DateTime now;
  DateFormat dateFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context){
    String dateString = dateFormat.format(now);
    // ジェスチャー（タップ、ドラッグ等）を可能にするため、CardをGestureDetectorで囲む
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: (){
      },
      // 情報の表示部分（カード）
      // カードのサイズ調整
      child: Container(
        width: size.width * 0.96,
        height: size.height * 0.22,
        child: Card(
          color: Color.fromARGB(255, 37, 37, 40),
          elevation: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 交通機関を示すアイコン
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "JR",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                          Icon(
                            MyIcons.train,
                            color: Colors.white,
                            size: size.width*0.12,
                          ),
                        ],
                      ),
                    ),
                    // 出発地、到着地を示すアイコン
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          MyIcons.apartment,
                          color: Colors.white,
                          size: size.width*0.09,
                        ),
                        Icon(
                          MyIcons.arrow_right,
                          color: Colors.white,
                          size: size.width*0.06,
                        ),
                        Icon(
                          MyIcons.graduation_hat,
                          color: Colors.white,
                          size: size.width*0.09,
                        ),
                      ],
                    )
                  ]
                ),
              ),
              Container(
                width: size.width * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 発車時刻
                    Text(
                      dateString,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.15
                      )
                    ),
                    // 発車までの時刻
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "30",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.13,
                            height: 1.0,
                          )
                        ),
                        Text(
                          " min left",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.04,
                            height: 3,
                          )
                        ),
                      ],
                    )
                  ]
                ),
              )
            ]
          )
        ),
      ),
    );
  }
}