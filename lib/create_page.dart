import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_exp/date_picker.dart';
import 'package:flutter_exp/model/category_item.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class CreatePage extends StatefulWidget {
  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  PickedFile _image;
  DateTime _expDate;
  List<CategoryItem> _dropdownItems = [
    CategoryItem(1, "식품"),
    CategoryItem(2, "화장품")
  ];
  List<DropdownMenuItem<CategoryItem>> _dropdownMenuItems;
  CategoryItem _selectedItem;

  @override
  void initState() {
    super.initState();

    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    _selectedItem = _dropdownMenuItems[0].value;
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
      backgroundColor: Colors.lightBlue[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
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
                      backgroundImage:
                          _image == null ? null : FileImage(File(_image.path)),
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
                      borderSide: BorderSide(color: Colors.lightBlue[50]),
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
                '카테고리 : ',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Container(width: 20,),
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
            children: [
              Text(
                '유통기한 : ',
                style: TextStyle(color: Colors.black, fontSize: 18),
              ),
              Container(width: 20,),
              Expanded(
                child: DatePicker(onDateTimeChanged: (dateTime) {
                  setState(() {
                    _expDate = dateTime;
                  });
                }),
              ),
            ],
          ),
        ],
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
      backgroundColor: Colors.lightBlue[50],
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

            final firebase_storage.Reference firebaseStorageRef =
                firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child('exp')
                    .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

            //storage에 파일을 업로드
            final firebase_storage.UploadTask task = firebaseStorageRef.putFile(
                file,
                firebase_storage.SettableMetadata(contentType: 'image/jpg'));

            firebase_storage.TaskSnapshot snapshot = await task;

            var downloadUrl = await snapshot.ref.getDownloadURL();
            var doc = FirebaseFirestore.instance.collection('exp').doc();
            doc.set({
              'id': doc.id,
              'photoUrl': downloadUrl,
              'title': _titleController.text,
              'category': _selectedItem.name,
              'expDate': _expDate,
            }).then((value) {
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
