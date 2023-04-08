import 'package:json_annotation/json_annotation.dart';
part 'test_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Abc {
  String? name;
  String? sku;
  double? price;
  ShipTo? shipTo;
  BillTo? billTo;
  Abc({this.name, this.sku, this.price, this.shipTo, this.billTo});
  factory Abc.fromJson(json) => _$AbcFromJson(json);
  Map<String, dynamic> toJson() => _$AbcToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ShipTo {
  String? name;
  String? address;
  String? city;
  String? state;
  String? zip;
  ShipTo({this.name, this.address, this.city, this.state, this.zip});
  factory ShipTo.fromJson(json) => _$ShipToFromJson(json);
  Map<String, dynamic> toJson() => _$ShipToToJson(this);
}

@JsonSerializable(explicitToJson: true)
class BillTo {
  String? name;
  String? address;
  String? city;
  String? state;
  String? zip;
  BillTo({this.name, this.address, this.city, this.state, this.zip});
  factory BillTo.fromJson(json) => _$BillToFromJson(json);
  Map<String, dynamic> toJson() => _$BillToToJson(this);
}
