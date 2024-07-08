class Response<T> {
  late int code;
  T? data;
  Map<String, dynamic>? meta;
  List<String>? errors;
  String? message;

  Response({
    required this.code,
    this.data,
    this.message,
    this.meta,
    this.errors,
  });

  Response.success(T this.data, {this.meta, this.message}) {
    this.code = 0;
  }

  Response.fail(this.code, this.message,
      {this.errors});

  bool isSuccess() {
    return code == 0;
  }
}
