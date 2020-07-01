// To parse this JSON data, do
//
//     final listDishesResponseModel = listDishesResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

ListDishesResponseModel listDishesResponseModelFromJson(String str) =>
    ListDishesResponseModel.fromJson(json.decode(str));

String listDishesResponseModelToJson(ListDishesResponseModel data) =>
    json.encode(data.toJson());

class ListDishesResponseModel {
  List<DishModel> listDishes;
  String message;

  ListDishesResponseModel({
    this.listDishes,
    this.message,
  });

  static ListDishesResponseModel fromJsonFactory(Map<String, dynamic> json) =>
      ListDishesResponseModel.fromJson(json);

  factory ListDishesResponseModel.fromJson(Map<String, dynamic> json) =>
      ListDishesResponseModel(
          listDishes: List<DishModel>.from(
              json["data"].map((x) => DishModel.fromJson(x))),
          message: json['message']);

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(listDishes.map((x) => x.toJson())),
        'message': message
      };
}

SingleDishResponseModel singleDishResponseModelFromJson(String str) => SingleDishResponseModel.fromJson(json.decode(str));

String singleDishResponseModelToJson(SingleDishResponseModel data) => json.encode(data.toJson());

class SingleDishResponseModel {
  String message;
  DishModel dishModel;

  SingleDishResponseModel({
    this.message,
    this.dishModel,
  });

  static SingleDishResponseModel fromJsonFactory(Map<String, dynamic> json) => SingleDishResponseModel.fromJson(json);

  factory SingleDishResponseModel.fromJson(Map<String, dynamic> json) => SingleDishResponseModel(
    message: json["message"],
    dishModel: DishModel.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": dishModel.toJson(),
  };
}

class DishModel {
  String id;
  String name;
  String description;
  int price;
  int priceNew;
  List<String> categories;
  int discount;
  int quantity;
  List<String> image;
  String featureImage;
  String currency;
  String updateAt;
  String createAt;

  DishModel({
    this.id,
    this.name,
    this.description,
    this.price,
    this.priceNew,
    this.quantity,
    this.categories,
    this.discount,
    this.image,
    this.featureImage,
    this.currency,
    this.updateAt,
    this.createAt,
  });

  static DishModel fromJsonFactory(Map<String, dynamic> json) =>
      DishModel.fromJson(json);

  factory DishModel.fromJson(Map<String, dynamic> json) => DishModel(
        id: json["_id"],
        name: json["name"],
        description: json["description"],
        price: json["price"],
        priceNew: json["price_new"],
        categories: List<String>.from(json["categories"].map((x) => x)),
        discount: json["discount"],
        quantity: 1,
        image: List<String>.from(json["image"].map((x) => x)),
        featureImage: json["feature_image"],
        currency: json["currency"],
        updateAt: json["updateAt"],
        createAt: json["createAt"],
      );

  factory DishModel.fromJsonDB(Map<String, dynamic> json) => DishModel(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    price: json["price"],
    priceNew: json["price_new"],
    categories: List<String>(),
    discount: json["discount"],
    quantity: 1,
    image: List<String>(),
    featureImage: json["feature_image"],
    currency: json["currency"],
    updateAt: json["updateAt"],
    createAt: json["createAt"],
  );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "description": description,
        "price": price,
        "price_new": priceNew,
        "categories": categories,
        "discount": discount,
        "image": List<dynamic>.from(image.map((x) => x)),
        "feature_image": featureImage,
        "currency": currency,
      };
}

List<CategoryDb> categoryDbFromJson(String str) => List<CategoryDb>.from(json.decode(str).map((x) => CategoryDb.fromJson(x)));

String categoryDbToJson(List<CategoryDb> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryDb {
  CategoryDb({
    this.id,
    this.dishId,
    this.category,
  });

  int id;
  String dishId;
  String category;

  factory CategoryDb.fromJson(Map<String, dynamic> json) => CategoryDb(
    id: json["id"],
    dishId: json["dish_id"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dish_id": dishId,
    "category": category,
  };
}

class ImageDb {
  ImageDb({
    this.id,
    this.dishId,
    this.image,
  });

  int id;
  String dishId;
  String image;

  factory ImageDb.fromJson(Map<String, dynamic> json) => ImageDb(
    id: json["id"],
    dishId: json["dish_id"],
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dish_id": dishId,
    "image": image,
  };
}

class CartModel extends Model {
  List<DishModel> cart = [];
  double totalCartValue = 0;
  String totalMoney;

  int get total => cart.length;

  void addProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    print(index);
    if (index != -1)
      updateProduct(product, product.quantity + 1);
    else {
      cart.add(product);
      calculateTotalBill();
      notifyListeners();
    }
  }

  void removeProduct(product) {
    int index = cart.indexWhere((i) => i.id == product.id);
    cart[index].quantity = 1;
    cart.removeWhere((item) => item.id == product.id);
    calculateTotalBill();
    notifyListeners();
  }

  void updateProduct(product, qty) {
    int index = cart.indexWhere((i) => i.id == product.id);
    cart[index].quantity = qty;
    if (cart[index].quantity == 0) removeProduct(product);

    calculateTotalBill();
    notifyListeners();
  }

  void clearCart() {
    cart.forEach((f) => f.quantity = 1);
    cart = [];
    notifyListeners();
  }

  void calculateTotalBill() {
    totalCartValue = 0;
    cart.forEach((f) {
      totalCartValue += f.priceNew * f.quantity;
    });

    int i = int.parse(totalCartValue.toStringAsFixed(
        totalCartValue.truncateToDouble() == totalCartValue ? 0 : 2));
    final f = new NumberFormat("#,###");
    totalMoney = f.format(i);
  }

  int calculateTotalItem() {
    int totalCartValue = 0;
    cart.forEach((f) {
      totalCartValue += f.quantity;
    });

    return totalCartValue;
  }
}



class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

