import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubjectModel {
  final String id;
  final String name;
  final int colorValue;
  final String icon;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;

  const SubjectModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.icon,
    this.isDefault = false,
    this.sortOrder = 0,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color_value'] as int,
      icon: map['icon'] as String,
      isDefault: (map['is_default'] as int) == 1,
      sortOrder: map['sort_order'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color_value': colorValue,
      'icon': icon,
      'is_default': isDefault ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  SubjectModel copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? icon,
    bool? isDefault,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
