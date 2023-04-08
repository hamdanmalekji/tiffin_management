// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Abc _$AbcFromJson(Map<String, dynamic> json) => Abc(
      name: json['name'] as String?,
      sku: json['sku'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      shipTo: json['shipTo'] == null ? null : ShipTo.fromJson(json['shipTo']),
      billTo: json['billTo'] == null ? null : BillTo.fromJson(json['billTo']),
    );

Map<String, dynamic> _$AbcToJson(Abc instance) => <String, dynamic>{
      'name': instance.name,
      'sku': instance.sku,
      'price': instance.price,
      'shipTo': instance.shipTo?.toJson(),
      'billTo': instance.billTo?.toJson(),
    };

ShipTo _$ShipToFromJson(Map<String, dynamic> json) => ShipTo(
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$ShipToToJson(ShipTo instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
    };

BillTo _$BillToFromJson(Map<String, dynamic> json) => BillTo(
      name: json['name'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$BillToToJson(BillTo instance) => <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'zip': instance.zip,
    };
