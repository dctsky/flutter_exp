import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exp/product_info.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import 'create_page.dart';
import 'menu_widget.dart';
import 'model/products.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  GlobalKey<SliderMenuContainerState> _key =
      new GlobalKey<SliderMenuContainerState>();
  String title;
  Widget body;

  @override
  void initState() {
    title = "Home";
    body = _buildBody();
    super.initState();
  }

  List _fetchList(List<QueryDocumentSnapshot> items) {
    if (this.title == "식품") {
      return items
          .map((e) => ProductInfo(e))
          .toList()
          .where((element) => element.snapshot.get('category') == "식품")
          .toList();
    } else if (this.title == "화장품") {
      return items
          .map((e) => ProductInfo(e))
          .toList()
          .where((element) => element.snapshot.get('category') == "화장품")
          .toList();
    } else {
      return items
          .map((e) => ProductInfo(e))
          .toList();
    }
  }

  Widget _buildBody() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('exp').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          //collection 아래의 모든 문서 가져오기.
          var items = snapshot.data.docs ?? [];
          //유통기한 날짜로 오름차순 정렬
          items.sort((a, b) => a.get('expDate').compareTo(b.get('expDate')));

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  color: Colors.lightBlue[50],
                  child: CustomScrollView(
                    scrollDirection: Axis.vertical,
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        sliver: SliverFixedExtentList(
                          //높이가 고정된 리스트를 보여주기위해 SliverFixedExtentList 을 사용
                          itemExtent: 110.0,
                          //itemExtent 는 행의 크기를 설정하는 속성이고 크기가 모두 같으면 그리는 속도가 빨라진다.
                          delegate: SliverChildListDelegate(_fetchList(items)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SliderMenuContainer(
          appBarColor: Colors.lightBlue[50],
          appBarHeight: 110,
          key: _key,
          sliderMenuOpenSize: 200,
          title: Text(
            title,
            style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w700),
          ),
          trailing: IconButton(
              icon: Icon(Icons.add),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreatePage()),
                );
              }),
          sliderMenu: MenuWidget(
            onItemClick: (title) {
              _key.currentState.closeDrawer();
              setState(() {
                this.title = title;
                this.body = _buildBody();
              });
            },
          ),
          sliderMain: body),
    );
  }
}
