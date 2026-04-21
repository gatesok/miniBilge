import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum ItemType {
  hat(1, 'Şapka'),
  glasses(2, 'Gözlük'),
  outfit(3, 'Kıyafet'),
  accessory(4, 'Aksesuar'),
  background(5, 'Arka Plan');

  final int value;
  final String displayName;

  const ItemType(this.value, this.displayName);

  static ItemType fromValue(int value) {
    return ItemType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ItemType.accessory,
    );
  }
}
