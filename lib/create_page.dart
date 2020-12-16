import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_exp/date_picker.dart';
import 'package:flutter_exp/model/category_item.dart';
import 'package:flutter_exp/time_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  PickedFile _image;
  DateTime _expDate;
  DateTime _notiTime;
  bool _isChecked = false;
  final List<CategoryItem> _dropdownItems = [
    CategoryItem(1, "식품"),
    CategoryItem(2, "화장품"),
    CategoryItem(3, "기타"),
  ];
  final List<CategoryItem> _dropdownTimeItems = [
    CategoryItem(1, "1일전"),
    CategoryItem(2, "2일전"),
    CategoryItem(3, "3일전"),
    CategoryItem(7, "7일전"),
  ];

  List<DropdownMenuItem<CategoryItem>> _dropdownMenuItems;
  List<DropdownMenuItem<CategoryItem>> _dropdownMenuTimeItems;
  CategoryItem _selectedItem;
  CategoryItem _selectedTimeItem;
  var _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();

    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _dropdownMenuTimeItems = buildDropDownMenuItems(_dropdownTimeItems);
    _selectedItem = _dropdownMenuItems[0].value;
    _selectedTimeItem = _dropdownTimeItems[0];

    //안드로이드 설정를 위한 Notification을 설정. 앱 아이콘으로 설정을 바꾸어 줄수 있고 현재 @mipmap/ic_launcher는 flutter 기본 아이콘을 사용하는 것.
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    //ios 알림 설정 : 소리, 뱃지 등을 설정할 수 있음.
    var initializationSettingsIOS = IOSInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future _scheduledNotification(
      String title, DateTime expDate, int notiDay, DateTime notiTime) async {
    var android = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high);
    var ios = IOSNotificationDetails();
    var detail = NotificationDetails(android: android, iOS: ios);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '유통기한 임박 제품',
      '$title의 유통기한이 얼마 남지 않았습니다.',
      _setNotiTime(expDate, notiDay, notiTime),
      detail,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _setNotiTime(DateTime expDate, int notiDay, DateTime notiTime) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // final now = tz.TZDateTime.now(tz.local);
    // var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
    //     10, 0);
    // DateTime notiDate = DateTime(expDate.year, expDate.month, expDate.day - 1);
    var scheduledDate = tz.TZDateTime(tz.local, expDate.year, expDate.month,
        expDate.day - notiDay, notiTime.hour, notiTime.minute);

    return scheduledDate;
  }

  List<DropdownMenuItem<CategoryItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<CategoryItem>> items = List();
    for (CategoryItem item in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(item.name),
          value: item,
        ),
      );
    }
    return items;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _titleController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: Column(
          children: [
            Row(
              children: [
                Stack(children: [
                  Container(
                      height: 80,
                      width: 80,
                      child: CircleAvatar(
                        backgroundColor: Colors.white70,
                        backgroundImage: _image == null
                            ? null
                            : FileImage(File(_image.path)),
                      )),
                  Container(
                    height: 80,
                    width: 80,
                    child: Center(
                      child: IconButton(
                          icon: Icon(Icons.add),
                          color: Colors.grey,
                          onPressed: () {
                            _getImage();
                          }),
                    ),
                  ),
                ]),
                Container(width: 15),
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: '이름',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.red[100]),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: TextStyle(fontSize: 18),
                    cursorColor: Colors.white,
                  ),
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  '카테고리',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Container(
                  width: 20,
                ),
                Expanded(
                  child: DropdownButton<CategoryItem>(
                      isExpanded: true,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      value: _selectedItem,
                      items: _dropdownMenuItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedItem = value;
                        });
                      }),
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  '유통기한',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Container(
                  width: 20,
                ),
                Expanded(
                  child: DatePicker(onDateTimeChanged: (dateTime) {
                    setState(() {
                      _expDate = dateTime;
                    });
                  }),
                ),
              ],
            ),
            Container(
              height: 20,
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '알림 받기',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Container(
                  width: 10,
                ),
                Switch(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value;
                      });
                    })
              ],
            ),
            Row(
              children: _isChecked ? [
                Text(
                  '알림 설정',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Container(
                  width: 10,
                ),
                Expanded(
                  child: DropdownButton<CategoryItem>(
                      isExpanded: true,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      value: _selectedTimeItem,
                      items: _dropdownMenuTimeItems,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeItem = value;
                        });
                      }),
                ),
                Expanded(child: TimePicker(onTimeChange: (dateTime) {
                  setState(() {
                    _notiTime = dateTime;
                  });
                })),
              ] : [],
            ),
            ElevatedButton(
                onPressed: () async {
                  await _flutterLocalNotificationsPlugin.cancelAll();
                  Navigator.pop(context);
                },
                child: Text('알림모두삭제')),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        "ADD A NEW ITEM",
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
      backgroundColor: Colors.grey[100],
      elevation: 0,
      actions: [
        FlatButton(
          child: Text(
            '저장',
            style: TextStyle(fontSize: 18),
          ),
          shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
          onPressed: () async {
            //PickedFile형태를 File형으로 변환
            final File file = File(_image.path);
            final String imageName =
                '${DateTime.now().millisecondsSinceEpoch}.jpg';

            final firebase_storage.Reference firebaseStorageRef =
                firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('exp')
                    .child('$imageName');

            //storage에 파일을 업로드
            final firebase_storage.UploadTask task = firebaseStorageRef.putFile(
                file,
                firebase_storage.SettableMetadata(contentType: 'image/jpg'));

            firebase_storage.TaskSnapshot snapshot = await task;

            var downloadUrl = await snapshot.ref.getDownloadURL();
            var doc = FirebaseFirestore.instance.collection('exp').doc();

            doc.set({
              'id': doc.id,
              'imageName': imageName,
              'imageUrl': downloadUrl,
              'title': _titleController.text,
              'category': _selectedItem.name,
              'expDate': _expDate,
            }).then((value) {
              if (_isChecked) {
                _scheduledNotification(_titleController.text, _expDate,
                    _selectedTimeItem.value, _notiTime);
              }
              Navigator.pop(context);
            });
          },
        ),
      ],
    );
  }

  Future _getImage() async {
    PickedFile image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 88);

    setState(() {
      _image = image;
    });
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    return file;
  }
}
