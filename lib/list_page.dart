import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exp/product_info.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';
import 'create_page.dart';
import 'menu_widget.dart';

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  GlobalKey<SliderMenuContainerState> _key =
      new GlobalKey<SliderMenuContainerState>();
  String title;
  Widget body;
  TextEditingController _textEditingController;
  String _query = "";
  String _filter = "all";
  int _itemCount, _closeCount, _expCount;

  @override
  void initState() {
    _itemCount = 0;
    _closeCount = 0;
    _expCount = 0;
    title = "전체보관함";
    body = _buildBody();
    super.initState();
  }

  List _fetchList(List<QueryDocumentSnapshot> items) {
    final DateTime todayDate = DateTime.now();
    List closeList = [];
    List expList = [];
    List filteredList = items
        .where(
            (e) => e.get('title').toLowerCase().contains(_query.toLowerCase()))
        .toList();

    if (this.title == "식품") {
      filteredList = filteredList
          .where((element) => element.get('category') == "식품")
          .toList();
    } else if (this.title == "화장품") {
      filteredList = filteredList
          .where((element) => element.get('category') == "화장품")
          .toList();
    } else if (this.title == "기타") {
      filteredList = filteredList
          .where((element) => element.get('category') == "기타")
          .toList();
    }
    _itemCount = filteredList.length;

    closeList = filteredList
        .where((element) =>
            (todayDate.difference(element.get('expDate').toDate()).inDays < 0 &&
                -3 <
                    todayDate
                        .difference(element.get('expDate').toDate())
                        .inDays) ||
            todayDate.difference(element.get('expDate').toDate()).inDays == 0)
        .toList();
    expList = filteredList
        .where((element) =>
            0 < todayDate.difference(element.get('expDate').toDate()).inDays)
        .toList();
    if (_filter == "close") {
      filteredList = closeList;
    } else if (_filter == "exp") {
      filteredList = expList;
    }
    _closeCount = closeList.length;
    _expCount = expList.length;

    return filteredList.map((e) => ProductInfo(e)).toList();
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

          return CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5.0,
                          horizontal: 20.0,
                        ),
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle, //컨테이너를 네모모양으로 만들어줌
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10.0, //자연스럽게 퍼지게
                              offset: Offset(5.0, 5.0), //x축, y축 그림자 정도 지정
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        child: Column(
                                          children: [
                                            Text(
                                              '전체',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.green[600],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              '$_itemCount',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _filter = "all";
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        child: Column(
                                          children: [
                                            Text(
                                              '유통기한임박',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.orange),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              '$_closeCount',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _filter = "close";
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        child: Column(
                                          children: [
                                            Text(
                                              '유통기한만료',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.red[400]),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              '$_expCount',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _filter = "exp";
                                          });
                                        },
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextField(
                        onChanged: (text) {
                          setState(() {
                            _query = text;
                          });
                        },
                        autofocus: false,
                        controller: _textEditingController,
                        cursorColor: Colors.white,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '검색',
                          hintStyle: TextStyle(color: Colors.grey),
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.red[100]),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Container(
                      height: 20,
                    ),
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                sliver: SliverFixedExtentList(
                  //높이가 고정된 리스트를 보여주기위해 SliverFixedExtentList 을 사용
                  itemExtent: 95.0,
                  //itemExtent 는 행의 크기를 설정하는 속성이고 크기가 모두 같으면 그리는 속도가 빨라진다.
                  delegate: SliverChildListDelegate(_fetchList(items)),
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
          appBarColor: Colors.grey[100],
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
          sliderMain: _buildBody()),
    );
  }
}
