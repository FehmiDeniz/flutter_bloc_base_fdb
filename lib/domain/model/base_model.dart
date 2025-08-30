abstract class BaseModel<T> {
  const BaseModel();

  Map<String, dynamic> toJson();
  
  T fromJson(Map<String, dynamic> json);
  
  T copyWith();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseModel<T> && other.runtimeType == runtimeType;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '$runtimeType()';
}

abstract class BaseResponseModel<T> extends BaseModel<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const BaseResponseModel({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'statusCode': statusCode,
      'errors': errors,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BaseResponseModel<T> &&
        other.success == success &&
        other.message == message &&
        other.data == data &&
        other.statusCode == statusCode &&
        other.errors == errors;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        message.hashCode ^
        data.hashCode ^
        statusCode.hashCode ^
        errors.hashCode;
  }
}

abstract class BasePaginationModel<T> extends BaseModel<T> {
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const BasePaginationModel({
    required this.data,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BasePaginationModel<T> &&
        other.data == data &&
        other.currentPage == currentPage &&
        other.totalPages == totalPages &&
        other.totalItems == totalItems &&
        other.itemsPerPage == itemsPerPage &&
        other.hasNextPage == hasNextPage &&
        other.hasPreviousPage == hasPreviousPage;
  }

  @override
  int get hashCode {
    return data.hashCode ^
        currentPage.hashCode ^
        totalPages.hashCode ^
        totalItems.hashCode ^
        itemsPerPage.hashCode ^
        hasNextPage.hashCode ^
        hasPreviousPage.hashCode;
  }
}
