class Product {
  final String id;
  final String name;
  final String category;
  final DateTime regDate;
  final DateTime expDate;
  final String image;

  Product({
    this.id,
    this.name,
    this.category,
    this.regDate,
    this.expDate,
    this.image,
  });
}

List<Product> products = [
  Product(
    id: "1",
    name: "핸드크림",
    category: "화장품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/hand_cream.jpg",
  ),
  Product(
    id: "2",
    name: "샴푸",
    category: "식품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/shampoo.jpg",
  ),
  Product(
    id: "1",
    name: "식품2",
    category: "식품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/hand_cream.jpg",
  ),
  Product(
    id: "1",
    name: "식품3",
    category: "식품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/hand_cream.jpg",
  ),
  Product(
    id: "1",
    name: "화장품2",
    category: "화장품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/hand_cream.jpg",
  ),
  Product(
    id: "1",
    name: "화장품3",
    category: "화장품",
    regDate: DateTime.now(),
    expDate: DateTime.now(),
    image: "assets/img/hand_cream.jpg",
  ),
];
