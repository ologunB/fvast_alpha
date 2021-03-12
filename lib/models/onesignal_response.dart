class OnesignalResponse {
  OnesignalResponse({
    this.type,
    this.message,
    this.data,
  });

  String type;
  String message;
  String data;

  factory OnesignalResponse.fromJson(Map<String, dynamic> json) =>
      OnesignalResponse(
        type: json["type"],
        message: json["message"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "message": message,
        "data": data,
      };
}
