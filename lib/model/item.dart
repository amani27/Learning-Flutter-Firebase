// To parse this JSON data, do
//
//     final item = itemFromJson(jsonString);

import 'dart:convert';

Item itemFromJson(String str) => Item.fromJson(json.decode(str));

String itemToJson(Item data) => json.encode(data.toJson());

class Item {
  Item({
    this.items,
  });

  List<ItemElement> items;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        items: json["items"] != null
            ? List<ItemElement>.from(
                json["items"].map((x) => ItemElement.fromJson(x)))
            : List<ItemElement>(),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class ItemElement {
  ItemElement({
    this.title,
    this.date,
    this.done,
  });

  String title;
  DateTime date;
  bool done;

  factory ItemElement.fromJson(Map<String, dynamic> json) => ItemElement(
        title: json["title"] == null ? null : json["title"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        done: json["done"] == null ? null : json["done"],
      );

  Map<String, dynamic> toJson() => {
        "title": title == null ? null : title,
        "date": date == null ? null : date.toIso8601String(),
        "done": done == null ? null : done,
      };
}
