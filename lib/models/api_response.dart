class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}

// Отдельный класс для статических методов
class ApiResponseHelper {
  static ApiResponse<T> success<T>(String message, T data) {
    return ApiResponse(success: true, message: message, data: data);
  }

  static ApiResponse<T> error<T>(String message) {
    return ApiResponse(success: false, message: message);
  }
}