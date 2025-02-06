class LeagueDetay {
  bool? success;
  List<Result>? result;

  LeagueDetay({this.success, this.result});

  LeagueDetay.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add(Result.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Result {
  final String rank;
  final String team;
  final String play;
  final String win;
  final String lose;
  final String point;

  Result({
    required this.rank,
    required this.team,
    required this.play,
    required this.win,
    required this.lose,
    required this.point,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      rank: json["rank"]?.toString() ?? "Bilinmiyor",
      team: json["team"]?.toString() ?? "Bilinmiyor",
      play: json["play"]?.toString() ?? "0",
      win: json["win"]?.toString() ?? "0",
      lose: json["lose"]?.toString() ?? "0",
      point: json["point"]?.toString() ?? "0",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rank'] = rank;
    data['lose'] = lose;
    data['win'] = win;
    data['play'] = play;
    data['point'] = point;
    data['team'] = team;
    return data;
  }
}
