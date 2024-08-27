import 'package:telo/models/resident_model.dart';

import 'building_model.dart';

class BuildingWithResidents {
  final String apartmentNumber;
  final String rentType;
  final String monthlyRentAmount;
  final String monthlyRentPaymentDate;
  final String deposit;
  final String contractExpirationDate;

  final List<String>? residentImageURL;

  final String buildingID;
  final String buildingName;
  final String buildingAddress;
  final String? notice;
  final String landlordID;
  final List<String>? buildingImageURL;

  BuildingWithResidents({
    required this.apartmentNumber,
    required this.rentType,
    required this.monthlyRentAmount,
    required this.monthlyRentPaymentDate,
    required this.deposit,
    required this.contractExpirationDate,
    this.residentImageURL,
    required this.buildingID,
    required this.buildingName,
    required this.buildingAddress,
    this.notice,
    required this.landlordID,
    this.buildingImageURL
  });

  factory BuildingWithResidents.fromJson(Map<String, dynamic> json) {
    return BuildingWithResidents(
      apartmentNumber: json['apartmentNumber'],
      rentType: json['rentType'],
      monthlyRentAmount: json['monthlyRentAmount'] as String? ?? '',
      monthlyRentPaymentDate: json['monthlyRentPaymentDate'] as String? ?? '',
      deposit: json['deposit'],
      contractExpirationDate: json['contractExpirationDate'],
      residentImageURL: List<String>.from(json['residentImageURL'] ?? []),

      buildingID: json['buildingID'],
      buildingName: json['buildingName'],
      buildingAddress: json['buildingAddress'],
      notice: json['notice'] as String? ?? '',
      landlordID: json['landlordID'],
      buildingImageURL: List<String>.from(json['buildingImageURL'] ?? []),
    );
  }
}