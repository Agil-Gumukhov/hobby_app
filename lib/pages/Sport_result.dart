class LeagueResults {
  bool? success;
  List<Result>? result;

  LeagueResults({this.success, this.result});

  LeagueResults.fromJson(Map<String, dynamic> json) {
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
  String? score;
  String? date;
  String? away;
  String? home;

  Result({this.score, this.date, this.away, this.home});

  Result.fromJson(Map<String, dynamic> json) {
    score = json['skor'];
    date = json['date'];
    away = json['away'];
    home = json['home'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['skor'] = score;
    data['date'] = date;
    data['away'] = away;
    data['home'] = home;
    return data;
  }
}