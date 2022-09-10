import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nholiday_jp/nholiday_jp.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'my_icons_icons.dart';

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
        textTheme: GoogleFonts.notoSansTextTheme(),
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
  Color backgroundColor = Color.fromARGB(255, 5, 0, 13);
  // Color backgroundColor = Colors.lightBlue;

  @override
  void initState() {
    // 1秒ごとに画面を更新するため、1秒ごとにsetStateを呼び出す
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    DateTime _now = DateTime.now();
    String weekdayName = getTimetableName(_now);
    DateFormat dateFormat = DateFormat('hh:mm:ss');
    String timeString = dateFormat.format(_now);
    return FutureBuilder(
      future:getMap(),
      builder:(context,snapshot){
        if(snapshot.hasData){
          Map<String,dynamic> _map = snapshot.data as Map<String,dynamic>;
          return Scaffold(
            // bodyの背景色を設定
            backgroundColor: backgroundColor,
            // appbarの実装
            appBar: AppBar(
              // 左側の戻るボタン
              leading: IconButton(
                // padding: EdgeInsets.zero,
                /* constraints: const BoxConstraints(
                  minHeight: 24.0,
                  minWidth: 24.0,
                ), */
                iconSize: size.width * 0.07,
                icon: const Icon(Icons.arrow_back_ios_new),
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
                  iconSize: size.width * 0.07,
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                  },
                ),
              ],
              // appbarの境界線を無くす
              elevation: 0,
              // appbarの背景色をbodyの背景色と同じに
              backgroundColor: backgroundColor,
              // appbarの高さを調整
              toolbarHeight: size.height * 0.05,
            ),
            body: Center(
              // カード表示時のアニメーションを追加
              child: AnimationLimiter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 400),
                    childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: size.width,
                      child: ScaleAnimation(
                        child: widget
                      ),
                    ),
                    children: [
                      for (String mapKey in _map.keys)...{
                        TimeTableCard(
                          map: _map,
                          mapKey: mapKey,
                          weekdayName: weekdayName,
                          size: size,
                          now: _now,
                        )
                      }
                    ]
                  ),
                ),
              )
            ),
          );
        }else{
          return Scaffold(
            backgroundColor: backgroundColor,
            body: SafeArea(
              child: Center(
                child: const Text("読み込み中です...")
              ),
            )
          );
        }
      }
    );
  }

  // timetable.jsonの読み込み
  // 非同期処理
  Future<Map<String, dynamic>> getMap() async {
    String path = "assets/json/timetable.json";
    String jsonString;
    jsonString = await rootBundle.loadString(path);
    Map<String,dynamic> result = jsonDecode(jsonString);
    return result;
  }

  // 曜日に即した時刻表のキーを取得する関数
  String getTimetableName(DateTime now) {
    // 曜日番号を取得
    int weekDayNam = now.weekday;
    // 今月の休日をリストで取得
    List<Holiday> checkHolidayList = NHolidayJp.getByMonth(now.year, now.month);
    // 休日のリストを日のみに整形
    final holidayDate = checkHolidayList.map((e) => "${e.date}");
    // 休日のリストに今日の日が入っていれば日を、そうでなければ「none」を取得
    String checkHoliday = holidayDate.firstWhere((e) => e == "${now.day}", orElse: () => "none");
    String timetableName;
    if (checkHoliday == "none"){
      if (weekDayNam <= 5){
        timetableName = "timetableWeekday";
      }else if (weekDayNam == 6){
        timetableName = "timetableSaturday";
      }else{
        timetableName = "timetableHoliday";
      }
    }else{
      timetableName = "timetableHoliday";
    }
    return timetableName;
  }
}

class TimeTableCard extends StatelessWidget{
  TimeTableCard({Key? key,
    required this.map,
    required this.mapKey,
    required this.now,
    required this.size,
    required this.weekdayName
  }) : super(key: key);
  Map<String, dynamic> map;
  String mapKey;
  String weekdayName;
  Size size;
  DateTime now;
  DateFormat dateFormat = DateFormat('HH:mm');
  Map<String, IconData> icons = {"bus": MyIcons.bus, "train": MyIcons.train, "graduation_hat": MyIcons.graduation_hat, "apartment": MyIcons.apartment};
  int digits = 2;
  double digitwidth = 30;

  @override
  Widget build(BuildContext context){
    // 日付や時間系
    List<String> twoDaysTimes = getTwoDaysTimes(now, map, mapKey);
    Map<String, dynamic> leftTimeMap = calcLeftTime(now, changeStringToDateTime(twoDaysTimes[0], now));
    // アイコンやテキスト系
    String textTraffic = map[mapKey]["textTraffic"];
    String textDeparture = map[mapKey]["textDeparture"];
    String textDestination = map[mapKey]["textDestination"];
    // ジェスチャー（タップ、ドラッグ等）を可能にするため、CardをGestureDetectorで囲む
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: (){
      },
      // 情報の表示部分（カード）
      // カードのサイズ調整
      child: SizedBox(
        width: size.width * 0.96,
        height: size.height * 0.22,
        child: Card(
          color: const Color.fromARGB(255, 37, 37, 40),
          // color: textTraffic == "JR" ? Colors.green : Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  // 交通機関を示すテキスト
                  Text(
                    textTraffic,
                    style: TextStyle(
                      color: textTraffic == "JR" ? Colors.green[400] : Colors.orange,
                      fontSize: size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 出発地を示すテキスト
                      Text(
                        textDeparture,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.05,
                        )
                      ),
                      // 右矢印
                      Text(
                        " → ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.06,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      /* Icon(
                        MyIcons.arrow_right,
                        color: Colors.white,
                        size: size.width*0.06,
                      ), */
                      // 目的地を示すテキスト
                      Text(
                        textDestination,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.05,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 10,)
                ],
              ),
              // 発車までの残り時間
              /* Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimeContainer(
                    timeText: leftTimeMap["leftTime"].substring(0, 2),
                    digits: digits,
                    digitWidth: digitwidth,
                    suffix: ":",
                    style: TextStyle(
                      color: leftTimeMap["checkLeftTime"] ? Colors.red : Colors.white,
                      fontSize: size.width * 0.13,
                    ),
                  ),
                  TimeContainer(
                    timeText: leftTimeMap["leftTime"].substring(3, 5),
                    digits: digits,
                    digitWidth: digitwidth,
                    suffix: ":",
                    style: TextStyle(
                      color: leftTimeMap["checkLeftTime"] ? Colors.red : Colors.white,
                      fontSize: size.width * 0.13,
                    ),
                  ),
                  TimeContainer(
                    timeText: leftTimeMap["leftTime"].substring(6, 8),
                    digits: digits,
                    digitWidth: digitwidth,
                    style: TextStyle(
                      color: leftTimeMap["checkLeftTime"] ? Colors.red : Colors.white,
                      fontSize: size.width * 0.13,
                    ),
                  ),
                ],
              ), */
              Text(
                leftTimeMap["leftTime"],
                style: TextStyle(
                  color: leftTimeMap["checkLeftTime"] ? Colors.red : Colors.white,
                  fontSize: size.width * 0.13,
                ),
              ),
              // 時刻等の表示
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 15),
                  // 次発の時刻を表示
                  Text(
                    twoDaysTimes[0],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.08
                    )
                  ),
                  const Spacer(flex: 5),
                  // 次々発の時刻を表示
                  Row(
                    children: [
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          ">> ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05
                          )
                        ),
                      ),
                      Opacity(
                        opacity: 0.8,
                        child: Text(
                          twoDaysTimes[1],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width * 0.05
                          )
                        ),
                      )
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ]
          )
        ),
      ),
    );
  }

  // 時間と分の文字列を、それ以外が今日の00秒であるDateTime型に変換する関数
  DateTime changeStringToDateTime(String time, DateTime now){
    String timeString = "${now}".replaceFirst(RegExp(r"\d{2}:\d{2}:\d{2}"), "${time}:00");
    DateTime dateTime = DateTime.parse(timeString);
    return dateTime;
  }

// 曜日に即した時刻表のキーを取得する関数(後で消す！！！！！！！！！)
  String getTimetableName(DateTime now) {
    // 曜日番号を取得
    int weekDayNam = now.weekday;
    // 今月の休日をリストで取得
    List<Holiday> checkHolidayList = NHolidayJp.getByMonth(now.year, now.month);
    // 休日のリストを日のみに整形
    final holidayDate = checkHolidayList.map((e) => "${e.date}");
    // 休日のリストに今日の日が入っていれば日を、そうでなければ「none」を取得
    String checkHoliday = holidayDate.firstWhere((e) => e == "${now.day}", orElse: () => "none");
    String timetableName;
    if (checkHoliday == "none"){
      if (weekDayNam <= 5){
        timetableName = "timetableWeekday";
      }else if (weekDayNam == 6){
        timetableName = "timetableSaturday";
      }else{
        timetableName = "timetableHoliday";
      }
    }else{
      timetableName = "timetableHoliday";
    }
    return timetableName;
  }

  // 次発と次々発の時刻を取得する関数
  List<String> getTwoDaysTimes(DateTime now, Map<String, dynamic> map, String mapKey) {
    // 今日のtimetableを取得
    List<dynamic> todayTimes = map[mapKey]["timetable"][getTimetableName(now)];
    // 明日のtimetableを取得
    List<dynamic> tomorrowTimes = map[mapKey]["timetable"][getTimetableName(now.add(const Duration(days:1)))];
    for (int i=0; i<todayTimes.length; i++) {
      DateTime timetableDateTime = changeStringToDateTime(todayTimes[i], now);
      if (now.isBefore(timetableDateTime)) {
        if (i!=todayTimes.length-1) {
          return [todayTimes[i], todayTimes[i+1], "today"];
        }else{
          return [todayTimes[i], tomorrowTimes[0], "last"];
        }
      }
    }
    return [tomorrowTimes[0], tomorrowTimes[1], "tomorrow"];
  }

  // 現在時刻と次発の時刻から、「残り時間」と「残り時間が5分以内であるかどうか」取得する関数
  Map<String, dynamic> calcLeftTime(DateTime now, DateTime tableTime) {
    bool checkLeftTime = false;
    // 現在時刻と次発の時刻の差を求める
    Duration diffDuration = tableTime.difference(now);
    // 差がマイナス（次発が翌日）であるとき、差に1日分の時間を加える
    if (diffDuration.inSeconds < 0) {
      diffDuration = tableTime.add(const Duration(days: 1)).difference(now);
    }
    String diffTimeString = diffDuration.toString();
    // 時間・分・秒のみにするため、小数点以下の秒数を削除
    String leftTime = diffTimeString.replaceFirst(RegExp(r".\d{6}"), "");
    // 時間が一桁のとき、頭に0を足して二桁に
    if (leftTime.length == 7){
      leftTime = "0" + leftTime;
    }
    // 残り時間が5分以内であれば文字を赤くするため、checkLeftTimeをtrueに
    if (diffDuration.inSeconds <= 300){
      checkLeftTime = true;
    }
    Map<String, dynamic> leftTimeMap = {"leftTime": leftTime, "checkLeftTime": checkLeftTime};
    // Map<String, dynamic> leftTimeMap = {"leftTime": DateFormat("hh:mm:ss").parse(leftTime), "checkLeftTime": checkLeftTime};
    return leftTimeMap;
  }
}

class TimeContainer extends StatelessWidget {
  final String timeText;
  final int digits;
  final double digitWidth;
  final String? suffix;
  final TextStyle? style;

  const TimeContainer({
    Key? key,
    required this.timeText,
    required this.digits,
    this.digitWidth = 4,
    this.suffix,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < digits; i++) ...[
          Container(
            alignment: Alignment.center,
            width: digitWidth,
            child: Text(
              timeText[i],
              style: style,
            ),
          ),
          if (i == digits - 1)
            Container(
              alignment: Alignment.center,
              child: Text(
                suffix ?? '',
                style: style,
              ),
            ),
        ],
      ],
    );
  }
}