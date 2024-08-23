class Resident {
  final String residentID;

  final String residentName;
  final String phoneNumber;
  final String apartmentNumber;
  final String rentType;

  final String monthlyRentAmount;
  final String monthlyRentPaymentDate;

  final String deposit;
  final String contractExpirationDate;

  final String buildingID;
  final String buildingName;
  final String notice;
  final List<String> imageURL;

  Resident({
    required this.residentID,

    required this.residentName,
    required this.phoneNumber,
    required this.apartmentNumber,
    required this.rentType,

    required this.monthlyRentAmount,
    required this.monthlyRentPaymentDate,

    required this.deposit,
    required this.contractExpirationDate,

    required this.buildingID,
    required this.buildingName,
    required this.notice,
    required this.imageURL,
  });

  factory Resident.fromJson(Map<String, dynamic> json) {
    return Resident(
      residentID: json['residentID'] ?? '',

      residentName: json['residentName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      rentType: json['rentType'] ?? '',

      monthlyRentAmount: json['monthlyRentAmount'] ?? '',
      monthlyRentPaymentDate: json['monthlyRentPaymentDate'] ?? '',

      deposit: json['deposit'] ?? '',
      contractExpirationDate: json['contractExpirationDate'] ?? '',

      buildingID: json['building']['buildingID'] ?? '',
      buildingName: json['building']['buildingName'] ?? '',
      notice: json['building']['notice'] ?? '',
      imageURL: List<String>.from(json['building']['imageURL']) ?? [],
    );
  }
}
