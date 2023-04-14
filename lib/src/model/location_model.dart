class Address {
  String? title;
  String? name;
  String? street;
  String? iSoCode;
  String? country;
  String? postalCode;
  String? adminArea;
  String? subAdminArea;
  String? locality;
  String? subLocality;
  String? thoroughfare;
  String? subThoroughFare;

  Address(
      {this.title,
      this.name,
      this.street,
      this.iSoCode,
      this.country,
      this.postalCode,
      this.adminArea,
      this.subAdminArea,
      this.locality,
      this.subLocality,
      this.subThoroughFare,
      this.thoroughfare});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        name: json['Name'],
        street: json['Street'],
        iSoCode: json['ISO Country Code'],
        country: json['Country'],
        postalCode: json['Postal code'],
        adminArea: json['Administrative area'],
        subAdminArea: json['Subadministrative area'],
        locality: json['Locality'],
        subLocality: json['Sublocality'],
        thoroughfare: json['Thoroughfare'],
        subThoroughFare: json['Subthoroughfare']);
  }

  factory Address.fromJsonDB(Map<String, dynamic> json) {
    return Address(
        title: json['title'],
        name: json['name'],
        street: json['street'],
        iSoCode: json['ISO Country Code']??"",
        country: json['country']??"",
        postalCode: json['postal_code']??"",
        adminArea: json['state']??"",
        subAdminArea: json['city']??"",
        locality: json['locality']??"",
        subLocality: json['Sublocality']??"",
        thoroughfare: json['Thoroughfare']??"",
        subThoroughFare: json['Subthoroughfare']??"");
  }

  Map<String, dynamic> toJSON() => {
        "Name": name,
        "Street": street,
        "ISO Country Code": iSoCode,
        "Country": country,
        "Postal code": postalCode,
        "Administrative area": adminArea,
        "Subadministrative area": subAdminArea,
        "Locality": locality,
        "Sublocality": subLocality,
        "Thoroughfare": thoroughfare,
        "Subthoroughfare": subThoroughFare
      };
}
