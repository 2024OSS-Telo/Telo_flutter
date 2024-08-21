class Building {
  final String buildingID;
  final String buildingName;
  final String buildingAddress;
  final int numberOfHouseholds;
  final int numberOfRentedHouseholds;
  final List<String> imageURL;
  final String notice;

  Building(
      {required this.buildingID,
        required this.buildingName,
        required this.buildingAddress,
        required this.numberOfHouseholds,
        required this.numberOfRentedHouseholds,
        required this.imageURL,
        required this.notice});

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      buildingID: json['buildingID'],
      buildingName: json['buildingName'],
      buildingAddress: json['buildingAddress'],
      numberOfHouseholds: json['numberOfHouseholds'],
      numberOfRentedHouseholds: json['numberOfRentedHouseholds'],
      imageURL: List<String>.from(json['imageURL']),
      notice: json['notice'],
    );
  }
}
