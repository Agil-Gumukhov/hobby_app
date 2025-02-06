class RestaurantsData {
  List<Businesses>? businesses;
  int? total;
  Region? region;

  RestaurantsData({this.businesses, this.total, this.region});

  RestaurantsData.fromJson(Map<String, dynamic> json) {
    if (json['businesses'] != null) {
      businesses = <Businesses>[];
      json['businesses'].forEach((v) {
        businesses!.add(Businesses.fromJson(v));
      });
    }
    total = json['total'];
    region =
        json['region'] != null ? Region.fromJson(json['region']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (businesses != null) {
      data['businesses'] = businesses!.map((v) => v.toJson()).toList();
    }
    data['total'] = total;
    if (region != null) {
      data['region'] = region!.toJson();
    }
    return data;
  }
}

class Businesses {
  String? id;
  String? alias;
  String? name;
  String? imageUrl;
  bool? isClosed;
  String? url;
  int? reviewCount;
  List<Categories>? categories;
  double? rating;
  Coordinates? coordinates;
  // Remove or change transactions type:
  // List<Null>? transactions; // Original
  List<dynamic>? transactions; // Revised
  Location? location;
  String? phone;
  String? displayPhone;
  double? distance;
  List<BusinessHours>? businessHours;
  Attributes? attributes;
  String? price;

  Businesses(
      {this.id,
      this.alias,
      this.name,
      this.imageUrl,
      this.isClosed,
      this.url,
      this.reviewCount,
      this.categories,
      this.rating,
      this.coordinates,
      this.transactions,
      this.location,
      this.phone,
      this.displayPhone,
      this.distance,
      this.businessHours,
      this.attributes,
      this.price});

  Businesses.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    alias = json['alias'];
    name = json['name'];
    imageUrl = json['image_url'];
    isClosed = json['is_closed'];
    url = json['url'];
    reviewCount = json['review_count'];
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    rating = json['rating'];
    coordinates = json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null;
    if (json['transactions'] != null) {
      transactions = json['transactions']; // Use as is or process if needed
    }
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    phone = json['phone'];
    displayPhone = json['display_phone'];
    distance = json['distance'];
    if (json['business_hours'] != null) {
      businessHours = <BusinessHours>[];
      json['business_hours'].forEach((v) {
        businessHours!.add(BusinessHours.fromJson(v));
      });
    }
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['alias'] = alias;
    data['name'] = name;
    data['image_url'] = imageUrl;
    data['is_closed'] = isClosed;
    data['url'] = url;
    data['review_count'] = reviewCount;
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    data['rating'] = rating;
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    if (transactions != null) {
      data['transactions'] = transactions; // or process accordingly
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['phone'] = phone;
    data['display_phone'] = displayPhone;
    data['distance'] = distance;
    if (businessHours != null) {
      data['business_hours'] = businessHours!.map((v) => v.toJson()).toList();
    }
    if (attributes != null) {
      data['attributes'] = attributes!.toJson();
    }
    data['price'] = price;
    return data;
  }
}

class Categories {
  String? alias;
  String? title;

  Categories({this.alias, this.title});

  Categories.fromJson(Map<String, dynamic> json) {
    alias = json['alias'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alias'] = alias;
    data['title'] = title;
    return data;
  }
}

class Coordinates {
  double? latitude;
  double? longitude;

  Coordinates({this.latitude, this.longitude});

  Coordinates.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class Location {
  String? address1;
  String? address2;
  String? address3;
  String? city;
  String? zipCode;
  String? country;
  String? state;
  List<String>? displayAddress;

  Location(
      {this.address1,
      this.address2,
      this.address3,
      this.city,
      this.zipCode,
      this.country,
      this.state,
      this.displayAddress});

  Location.fromJson(Map<String, dynamic> json) {
    address1 = json['address1'];
    address2 = json['address2'];
    address3 = json['address3'];
    city = json['city'];
    zipCode = json['zip_code'];
    country = json['country'];
    state = json['state'];
    displayAddress = json['display_address'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address1'] = address1;
    data['address2'] = address2;
    data['address3'] = address3;
    data['city'] = city;
    data['zip_code'] = zipCode;
    data['country'] = country;
    data['state'] = state;
    data['display_address'] = displayAddress;
    return data;
  }
}

class BusinessHours {
  List<Open>? open;
  String? hoursType;
  bool? isOpenNow;

  BusinessHours({this.open, this.hoursType, this.isOpenNow});

  BusinessHours.fromJson(Map<String, dynamic> json) {
    if (json['open'] != null) {
      open = <Open>[];
      json['open'].forEach((v) {
        open!.add(Open.fromJson(v));
      });
    }
    hoursType = json['hours_type'];
    isOpenNow = json['is_open_now'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (open != null) {
      data['open'] = open!.map((v) => v.toJson()).toList();
    }
    data['hours_type'] = hoursType;
    data['is_open_now'] = isOpenNow;
    return data;
  }
}

class Open {
  bool? isOvernight;
  String? start;
  String? end;
  int? day;

  Open({this.isOvernight, this.start, this.end, this.day});

  Open.fromJson(Map<String, dynamic> json) {
    isOvernight = json['is_overnight'];
    start = json['start'];
    end = json['end'];
    day = json['day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_overnight'] = isOvernight;
    data['start'] = start;
    data['end'] = end;
    data['day'] = day;
    return data;
  }
}

class Attributes {
  Null businessTempClosed;
  String? menuUrl;
  Null open24Hours;
  Null waitlistReservation;

  Attributes(
      {this.businessTempClosed,
      this.menuUrl,
      this.open24Hours,
      this.waitlistReservation});

  Attributes.fromJson(Map<String, dynamic> json) {
    businessTempClosed = json['business_temp_closed'];
    menuUrl = json['menu_url'];
    open24Hours = json['open24_hours'];
    waitlistReservation = json['waitlist_reservation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_temp_closed'] = businessTempClosed;
    data['menu_url'] = menuUrl;
    data['open24_hours'] = open24Hours;
    data['waitlist_reservation'] = waitlistReservation;
    return data;
  }
}

class Region {
  Coordinates? center;

  Region({this.center});

  Region.fromJson(Map<String, dynamic> json) {
    center = json['center'] != null
        ? Coordinates.fromJson(json['center'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (center != null) {
      data['center'] = center!.toJson();
    }
    return data;
  }
}
