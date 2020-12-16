import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductInfo extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;

  ProductInfo(this.snapshot);

  @override
  Widget build(BuildContext context) {
    final DateTime expDate = snapshot.get('expDate').toDate();
    final DateTime todayDate = DateTime.now();
    final int difference = todayDate.difference(expDate).inDays;
    final int difference_hours = (todayDate.difference(expDate).inHours).abs();
    String dDay = '';
    Color dDayColor;
    if (-3 < difference && difference <= 0) {
      dDay = 'D$difference';
      dDayColor = Colors.orange;
      if (difference == 0) {
        if (expDate.day != todayDate.day) {
          dDay = '$difference_hours시간 남음';
        } else {
          dDay = 'D-0';
        }
      }
    } else if (0 < difference) {
      dDay = 'D+$difference';
      dDayColor = Colors.red[400];
    } else {
      dDay = 'D$difference';
      dDayColor = Colors.green[600];
    }

    final CardContent = Container(
      margin: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0), //카드 안의 여백 지정
      // constraints: BoxConstraints.expand(), //크기에 제약조건 주는 것
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(snapshot.get('title'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  )),
              Container(
                height: 25,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: Text(
                    '$dDay',
                    style: TextStyle(
                        color: dDayColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          Container(height: 10.0),
          Text(
            '유통기한 : ${DateFormat('yyyy.MM.dd').format(snapshot.get('expDate').toDate())}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
    final productThumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(50.0),
      child: Image(
        image: NetworkImage(snapshot.get('imageUrl')),
        height: 70.0,
        width: 70.0,
        fit: BoxFit.cover,
      ),
    );

    return GestureDetector(
        onTap: () {},
        child: Slidable(
          actionPane: SlidableDrawerActionPane(),
          actionExtentRatio: 0.25,
          actions: [
            IconSlideAction(
              caption: '수정',
              color: Colors.green,
              icon: Icons.create,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => UpdatePage(todo)),
                // ).then((value) => _fetchList());
              },
            ),
          ],
          secondaryActions: [
            IconSlideAction(
              caption: '삭제',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text("${snapshot.get('title')} 삭제하시겠습니까?"),
                        actions: <Widget>[
                          FlatButton(
                            child: new Text("취소"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: new Text("삭제"),
                            onPressed: () {
                              final firebase_storage.Reference
                                  firebaseStorageRef = firebase_storage
                                      .FirebaseStorage.instance
                                      .ref()
                                      .child('exp')
                                      .child('${snapshot.get('imageName')}');

                              firebaseStorageRef.delete();

                              FirebaseFirestore.instance
                                  .collection("exp")
                                  .doc("${snapshot.get("id")}")
                                  .delete();

                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ],
          child: Container(
            // decoration: BoxDecoration(
            //   color: Colors.grey[100],
            //   shape: BoxShape.rectangle, //컨테이너를 네모모양으로 만들어줌
            //   borderRadius: BorderRadius.circular(10.0),
            //   boxShadow: <BoxShadow>[
            //     BoxShadow(
            //       color: Colors.grey[400],
            //       offset: Offset(2.0, 4.0),
            //       blurRadius: 5.0,
            //       spreadRadius: 1.0,
            //     ),
            //   ],
            // ),
            //전체 컨테이너 안에 card 컨테이너와 썸네일 컨테이너 stack
            margin: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: 20.0,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: productThumbnail,
                ),
                Expanded(child: CardContent),
              ],
            ),
          ),
        ));
  }
}
