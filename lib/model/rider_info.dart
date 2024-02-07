class RiderInfo {
  String? name;
  String? email;
  String? phone;
  String? photoUrl;
  Coordinates? coordinates;
  String? licensePlate;

  RiderInfo({
    this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.coordinates,
    this.licensePlate,
  });
}

class Coordinates {
  num? latitude;
  num? longitude;

  Coordinates({this.latitude, this.longitude});
}
