class DailyClipModel {
  final String url;
  final String clipId;

  DailyClipModel({required this.url, required this.clipId});

  // Factory constructor to create a DailyClip object from a JSON map
  factory DailyClipModel.fromJson(Map<String, dynamic> json) {
    return DailyClipModel(
      url: json['data']['url'],
      clipId: json['data']['clipId'],
    );
  }
}
