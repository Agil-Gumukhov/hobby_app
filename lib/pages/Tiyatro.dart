class Theathres {
  List<TheathresItem>? result;

  Theathres({this.result});

  Theathres.fromJson(Map<String, dynamic> json) {
    if (json['result'] != null) {
      result = <TheathresItem>[];
      json['result'].forEach((v) {
        result!.add(TheathresItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TheathresItem {
  String? image;
  String? title;
  String? sahne;
  String? url;

  TheathresItem({this.image, this.title, this.sahne, this.url});

  TheathresItem.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    title = json['title'];
    sahne = json['sahne'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['image'] = image;
    data['title'] = title;
    data['sahne'] = sahne;
    data['url'] = url;
    return data;
  }
}
