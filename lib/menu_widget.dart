import 'package:flutter/material.dart';

class MenuWidget extends StatelessWidget {
  final Function(String) onItemClick;

  const MenuWidget({Key key, this.onItemClick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.green[50]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: 100,
          ),
          CircleAvatar(
            radius: 61,
            backgroundColor: Colors.white70,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/img/seol2.jpg'),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Liszt',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 24,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          sliderItem('홈', Icons.home),
          sliderItem('전체보기', Icons.list),
          sliderItem('식품', Icons.list),
          sliderItem('화장품', Icons.list),
          sliderItem('Setting', Icons.settings),
        ],
      ),
    );
  }

  Widget sliderItem(String title, IconData icons) => ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: Icon(
        icons,
        color: Colors.black87,
      ),
      onTap: () {
        onItemClick(title);
      });
}
