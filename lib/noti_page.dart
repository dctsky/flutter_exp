import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotiPage extends StatefulWidget {
  @override
  _NotiPageState createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> {
  var _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    //안드로이드 설정를 위한 Notification을 설정. 앱 아이콘으로 설정을 바꾸어 줄수 있고 현재 @mipmap/ic_launcher는 flutter 기본 아이콘을 사용하는 것.
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    //ios 알림 설정 : 소리, 뱃지 등을 설정할 수 있음.
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //onSelectNotification의 경우 알림을 눌렀을때 어플에서 실행되는 행동을 설정하는 부분
    //눌렀을 때 어떤 행동을 취하게 하고 싶지 않다면 그냥 비워 두면 됨.
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  //알림을 눌렀을때 어떤 행동을 할지 정해주는 부분
  Future onSelectNotification(String payload) async {
    print("payload : $payload");
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text('우왕 잘됩니다!!!!우와아아아아아아앙!!!'),
              content: Text('Payload: $payload'),
            ));
  }

//await _flutterLocalNotificationPlugin.~ 에서 payload부분은 모두 설정하여 주지 않아도 됩니다.
//예약알림
  Future _scheduledNotification(DateTime expDate) async {
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '스케줄 Notification',
      '스케줄 Notification 내용',
      _setNotiTime(expDate),
      detail,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'Hello Flutter',
    );
  }
  tz.TZDateTime _setNotiTime(DateTime expDate) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    final now = tz.TZDateTime.now(tz.local);
    // var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
    //     10, 0);
    var scheduledDate = tz.TZDateTime(tz.local, expDate.year, expDate.month, expDate.day,
        3, 40);

    return scheduledDate;
  }
//버튼을 눌렀을때 한번 알림이 뜨게 해주는 방법입니다.
  Future _showNotification() async {
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.show(
      0,
      '단일 Notification',
      '단일 Notification 내용',
      detail,
      payload: 'Hello Flutter',
    );
  }

//매일 같은 시간 알림을 알려줍니다.
  Future _dailyAtTimeNotification() async {
    //시간은 24시간으로 표시.
    var time = Time(1, 36, 0);
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      0,
      '매일 똑같은 시간의 Notification',
      '매일 똑같은 시간의 Notification 내용',
      time,
      detail,
      payload: 'Hello Flutter',
    );
  }

//반복적으로 알림을 뜨게 히는 방법입니다.
  Future _repeatNotification() async {
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);

    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '반복 Notification',
      '반복 Notification 내용',
      //ReapeatInterval.{everyMinute, Hourly, Daily, Weekly} 중 선택
      RepeatInterval.everyMinute,
      detail,
      payload: 'Hello Flutter',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              onPressed: _showNotification,
              child: Text('Show Notification'),
            ),
            RaisedButton(
              onPressed: _dailyAtTimeNotification,
              child: Text('Daily At Time Notification'),
            ),
            RaisedButton(
              onPressed: _repeatNotification,
              child: Text('Repeat Notification'),
            ),
            // RaisedButton(
            //   onPressed: _scheduledNotification,
            //   child: Text('Scheduled Notification'),
            // ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
