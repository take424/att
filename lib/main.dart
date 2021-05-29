import 'package:flutter/material.dart';
import 'package:att/att.dart'; // 追加
import 'package:att/banner_ad_widget.dart'; // 追加
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 追加

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // 追加

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isATTPermission = false; // 追加

  @override
  void initState() {
    super.initState();

    // ここから追加
    ATT.instance.requestPermission().then((result) {
      setState(() {
        isATTPermission = result;
        if (isATTPermission) {
          // ATTの許可が取れたので広告バナーを初期化する
          MobileAds.instance.initialize();
        }
      });
    });
    // ここまで追加
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATT Sample'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('hello ATT.'),
            // ここから追加
            Visibility(
              // ATTの許可が取れたので広告バナーを表示する
              visible: isATTPermission,
              child: BannerAdWidget(),
            ),
            // ここまで追加
          ],
        ),
      ),
    );
  }
}
