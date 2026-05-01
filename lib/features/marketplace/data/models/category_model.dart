import 'package:pocketbase/pocketbase.dart';
import 'package:equatable/equatable.dart';

/// Kategori veri modeli — PocketBase ile uyumlu
class CategoryModel extends Equatable {
  final String categoryId;
  final String nameTr;
  final String nameEn;
  final String icon;
  final String color;
  final int appCount;
  final int order;

  const CategoryModel({
    required this.categoryId,
    required this.nameTr,
    required this.nameEn,
    this.icon = '',
    this.color = '',
    this.appCount = 0,
    this.order = 0,
  });

  factory CategoryModel.fromPocketBase(RecordModel record) {
    return CategoryModel(
      categoryId: record.id,
      nameTr: record.getStringValue('nameTr'),
      nameEn: record.getStringValue('nameEn'),
      icon: record.getStringValue('icon'),
      color: record.getStringValue('color'),
      appCount: record.getIntValue('appCount'),
      order: record.getIntValue('order'),
    );
  }

  Map<String, dynamic> toPocketBase() {
    return {
      'nameTr': nameTr,
      'nameEn': nameEn,
      'icon': icon,
      'color': color,
      'appCount': appCount,
      'order': order,
    };
  }

  @override
  List<Object?> get props => [categoryId, nameTr, order];
}
