import 'package:flutter/material.dart';
import 'package:flutter_exp/model/products.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductInfo extends StatelessWidget {
  final QueryDocumentSnapshot snapshot;

  ProductInfo(this.snapshot);

  @override
  Widget build(BuildContext context) {
    final expDate = snapshot.get('expDate').toDate();
    final todayDate = DateTime.now();
    final difference = todayDate.difference(expDate).inDays;
    String dDay = '';
    Color dDayColor;
    if (difference == 0) {
      dDay = 'D-';
      dDayColor = Colors.red;
    } else if (0 < difference) {
      dDay = 'D+';
      dDayColor = Colors.red;
    } else {
      dDay = 'D';
      dDayColor = Colors.green[600];
    }

    final CardContent = Container(
      margin: EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0), //카드 안의 여백 지정
      constraints: BoxConstraints.expand(), //크기에 제약조건 주는 것
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
                    color: Colors.grey,
                    fontSize: 16,
                  )),
              Container(
                height: 20,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: Colors.lightBlue[50],
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0,
                      offset: Offset(5.0, 5.0),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '$dDay$difference',
                    style: TextStyle(
                        color: dDayColor,
                        fontSize: 16,
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
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    final productThumbnail = Container(
      height: 95.0,
      alignment: Alignment.centerLeft, //사이즈는 현재 부모컨테이너와 동일
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.0),
        child: Image(
          image: NetworkImage(snapshot.get('photoUrl')),
          height: 80.0,
          width: 80.0,
          fit: BoxFit.cover,
        ),
      ),
    );
    final productCard = Container(
      child: CardContent,
      height: 95.0,
      margin: EdgeInsets.only(left: 46.0), //왼쪽만 margin을 줘서 썸네일자리 확보
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle, //컨테이너를 네모모양으로 만들어줌
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0, //자연스럽게 퍼지게
            offset: Offset(0.0, 5.0), //x축, y축 그림자 정도 지정
          ),
        ],
      ),
    );

    return GestureDetector(
        onTap: () {},
        child: Container(
          //전체 컨테이너 안에 card 컨테이너와 썸네일 컨테이너 stack
          margin: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 20.0,
          ),
          child: Stack(
            children: <Widget>[
              productCard,
              productThumbnail,
            ],
          ),
        ));
  }
}
