import 'package:equatable/equatable.dart';

/// Kategori domain entity'si
class CategoryEntity extends Equatable {
  final String categoryId;
  final String nameTr;
  final String nameEn;
  final String icon;
  final String color;
  final int appCount;
  final int order;

  const CategoryEntity({
    required this.categoryId,
    required this.nameTr,
    required this.nameEn,
    this.icon = '',
    this.color = '',
    this.appCount = 0,
    this.order = 0,
  });

  /// Locale'e göre isim döndürür
  String getName(String locale) => locale == 'tr' ? nameTr : nameEn;

  @override
  List<Object?> get props => [categoryId, nameTr, order];
}
