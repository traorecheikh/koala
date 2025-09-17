class Result<T> {
  final T? data;
  final String? message;
  final bool isSuccess;

  Result._({this.data, this.message, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.error(String message) {
    return Result._(message: message, isSuccess: false);
  }

  bool get isError => !isSuccess;
}
