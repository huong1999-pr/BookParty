// To parse this JSON data, do
//
//     final partyBookResponseModel = partyBookResponseModelFromJson(jsonString);

import 'dart:convert';

PartyBookResponseModel partyBookResponseModelFromJson(String str) => PartyBookResponseModel.fromJson(json.decode(str));

String partyBookResponseModelToJson(PartyBookResponseModel data) => json.encode(data.toJson());

class PartyBookResponseModel {
  String message;
  Bill bill;

  PartyBookResponseModel({
    this.message,
    this.bill,
  });

  static PartyBookResponseModel fromJsonFactory(Map<String, dynamic> json) =>
      PartyBookResponseModel.fromJson(json);

  factory PartyBookResponseModel.fromJson(Map<String, dynamic> json) => PartyBookResponseModel(
    message: json["message"],
    bill: Bill.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": bill.toJson(),
  };
}

class Bill {
  DateTime dateParty;
  int table;
  int countCustomer;
  List<Dish> dishes;
  int total;
  String customer;
  DateTime createAt;
  int confirmStatus;
  DateTime confirmAt;
  String confirmBy;
  String confirmNote;
  String currency;
  int paymentStatus;
  int paymentType;
  DateTime paymentAt;
  String paymentBy;
  String id;

  Bill({
    this.dateParty,
    this.table,
    this.countCustomer,
    this.dishes,
    this.total,
    this.customer,
    this.createAt,
    this.confirmStatus,
    this.confirmAt,
    this.confirmBy,
    this.confirmNote,
    this.currency,
    this.paymentStatus,
    this.paymentType,
    this.paymentAt,
    this.paymentBy,
    this.id,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    dateParty: DateTime.parse(json["date_party"]),
    table: json["table"],
    countCustomer: json["count_customer"],
    dishes: List<Dish>.from(json["dishes"].map((x) => Dish.fromJson(x))),
    total: json["total"],
    customer: json["customer"],
    createAt: DateTime.parse(json["create_at"]),
    confirmStatus: json["confirm_status"],
    confirmAt: DateTime.parse(json["confirm_at"]),
    confirmBy: json["confirm_by"],
    confirmNote: json["confirm_note"],
    currency: json["currency"],
    paymentStatus: json["payment_status"],
    paymentType: json["payment_type"],
    paymentAt: DateTime.parse(json["payment_at"]),
    paymentBy: json["payment_by"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "date_party": dateParty.toIso8601String(),
    "table": table,
    "count_customer": countCustomer,
    "dishes": List<dynamic>.from(dishes.map((x) => x.toJson())),
    "total": total,
    "customer": customer,
    "create_at": createAt.toIso8601String(),
    "confirm_status": confirmStatus,
    "confirm_at": confirmAt.toIso8601String(),
    "confirm_by": confirmBy,
    "confirm_note": confirmNote,
    "currency": currency,
    "payment_status": paymentStatus,
    "payment_type": paymentType,
    "payment_at": paymentAt.toIso8601String(),
    "payment_by": paymentBy,
    "_id": id,
  };
}

class Dish {
  String id;
  int count;
  String name;
  String featureImage;
  int price;
  int discount;
  String currency;
  int totalMoney;

  Dish({
    this.id,
    this.count,
    this.name,
    this.featureImage,
    this.price,
    this.discount,
    this.currency,
    this.totalMoney,
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    id: json["_id"],
    count: json["count"],
    name: json["name"],
    featureImage: json["feature_image"],
    price: json["price"],
    discount: json["discount"],
    currency: json["currency"],
    totalMoney: json["total_money"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "count": count,
    "name": name,
    "feature_image": featureImage,
    "price": price,
    "discount": discount,
    "currency": currency,
    "total_money": totalMoney,
  };
}