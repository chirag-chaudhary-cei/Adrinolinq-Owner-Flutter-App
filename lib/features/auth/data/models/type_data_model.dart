import 'package:equatable/equatable.dart';

class TypeMasterId {
  TypeMasterId._();

  static const int nameTitle = 1;
  static const int gender = 2;
  static const int bloodGroup = 16;
  static const int tshirtSize = 17;
  static const int foodPreference = 20;
}

class TypeDataRequest extends Equatable {
  const TypeDataRequest({required this.typeMasterId});

  final int typeMasterId;

  Map<String, dynamic> toJson() => {'typeMasterId': typeMasterId};

  @override
  List<Object?> get props => [typeMasterId];
}

class TypeDataItem extends Equatable {
  const TypeDataItem({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory TypeDataItem.fromJson(Map<String, dynamic> json) {
    return TypeDataItem(
      id: json['id'] as int? ?? json['typeDataId'] as int? ?? 0,
      name: json['title'] as String? ??
          json['typeDataName'] as String? ??
          json['name'] as String? ??
          '',
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (description != null) 'description': description,
      };

  @override
  List<Object?> get props => [id, name, description];
}

class TypeDataResponse extends Equatable {
  const TypeDataResponse({
    this.success = true,
    required this.items,
    this.message,
  });

  final bool success;
  final List<TypeDataItem> items;
  final String? message;

  factory TypeDataResponse.fromJson(Map<String, dynamic> json) {
    final responseCode = json['response_code'] as String?;
    final isSuccess = responseCode == '200';
    final obj = json['obj'];

    List<TypeDataItem> items = [];
    if (obj is List) {
      items = obj
          .map((e) => TypeDataItem.fromJson(e as Map<String, dynamic>))
          .toList()
          .reversed
          .toList();
    }

    return TypeDataResponse(
      success: isSuccess,
      items: items,
      message: isSuccess ? null : obj?.toString(),
    );
  }

  @override
  List<Object?> get props => [success, items, message];
}
