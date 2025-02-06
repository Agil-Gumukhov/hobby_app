class GolKralligiData {
	bool? success;
	List<Result>? result;

	GolKralligiData({this.success, this.result});

	GolKralligiData.fromJson(Map<String, dynamic> json) {
		success = json['success'];
		if (json['result'] != null) {
			result = <Result>[];
			json['result'].forEach((v) { result!.add(Result.fromJson(v)); });
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
	String? play;
	String? goals;
	String? name;

	Result({this.play, this.goals, this.name});

	Result.fromJson(Map<String, dynamic> json) {
		play = json['play'];
		goals = json['goals'];
		name = json['name'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = <String, dynamic>{};
		data['play'] = play;
		data['goals'] = goals;
		data['name'] = name;
		return data;
	}
}