import 'dart:html';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'JR & Bus TimeTable'),
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

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final _key = GlobalKey();
    final cardWidth = _key.currentContext!.size!.width;
    final cardHeight = _key.currentContext!.size!.height;
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
          iconSize: 20,
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
      body: Container(
        key: _key,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: GridView.count(
            crossAxisCount: 1,
            children: [
              for(int i=0; i<4; i++)...{
                TimeTableCard(size: size)
              }
            ],
        ),
            /*child: SizedBox(
              width: 100,
              height: 100,
              child: ListTile(
                leading: Icon(Icons.access_alarm, size:100.0),
                title: Text("13:55"),
                subtitle: Text("あとx分"),
                trailing: Icon(Icons.abc_outlined),
              ),
            ),*/
      )
    );
  }
}

class TimeTableCard extends StatelessWidget{
  // const TimeTableCard({Key? key, required this.size}) : super(key: key);
  const TimeTableCard({Key? key, required this.size}) : super(key: key);
  final Size size;

  @override
  Widget build(BuildContext context){
    // ジェスチャー（タップ、ドラッグ等）を可能にするため、CardをGestureDetectorで囲む
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onTap: (){
      },
      // 情報の表示部分（カード）
      child: Container(
        width: size.width * 0.9,
        height: size.height * 0.2,
        alignment: Alignment.center,
        child: Card(
          color: Color.fromARGB(255, 37, 37, 40),
          elevation: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // カードのサイズ調整
              Column(
                children: [
                  // 交通機関を示すアイコン
                  Icon(
                    Icons.train,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  // 出発地、到着地を示すアイコン
                  Icon(
                    Icons.school,
                    color: Color.fromARGB(255, 255, 255, 255),
                  )
                ]
              ),
              Column(
                children: [
                  // 発車時刻
                  Text(
                    "15:10",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)
                    ),
                  ),
                  // 発車までの時刻
                  Text(
                    "あと30分",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)
                    ),
                  ),
                ]
              )
            ]
          )
        ),
      ),
    );
  }
}