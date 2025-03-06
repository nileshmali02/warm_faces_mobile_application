class VideoClipsModel {
  final String id;
  final String userId;
  final String url;
  final String status;
  final bool show;
  final DateTime createdAt;
  final DateTime updatedAt;

  VideoClipsModel({
    required this.id,
    required this.userId,
    required this.url,
    required this.status,
    required this.show,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoClipsModel.fromJson(Map<String, dynamic> json) {
    return VideoClipsModel(
      id: json['_id'],
      userId: json['userId'],
      url: json['url'],
      status: json['status'],
      show: json['show'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
