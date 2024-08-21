enum RepairState{
  NONE, REFUSAL, UNDER_REPAIR, CLAIM, COMPLETE
}

class RepairRequest {
  final String requestID;
  final String landlordID;
  final String tenantID;
  final String requestTitle;
  final String requestContent;
  late String claimContent;
  final int estimatedValue;
  late int actualValue;
  final DateTime createdDate;
  late String refusalReason;
  final List<String> imageURL;
  late List<String> receiptImageURL;
  RepairState repairState;

  RepairRequest({
    required this.requestID,
    required this.landlordID,
    required this.tenantID,
    required this.requestTitle,
    required this.requestContent,
    required this.estimatedValue,
    required this.createdDate,
    required this.imageURL,
    required this.repairState,
    this.claimContent = '',
    this.actualValue = 0,
    this.refusalReason = '',
    this.receiptImageURL = const []
});

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'landlordID': landlordID,
      'tenantID': tenantID,
      'requestTitle': requestTitle,
      'requestContent': requestContent,
      'claimContent': claimContent,
      'estimatedValue': estimatedValue,
      'actualValue': actualValue,
      'refusalReason' : refusalReason,
      'createdDate': createdDate.toIso8601String(),
      'imageURL': imageURL,
      'receiptImageURL': receiptImageURL,
      'repairState': repairState.toString().split('.').last,
    };
  }

  factory RepairRequest.fromJson(Map<String, dynamic> json) {
    return RepairRequest(
      requestID: json['requestID'],
      landlordID: json['landlordID'],
      tenantID: json['tenantID'],
      requestTitle: json['requestTitle'],
      requestContent: json['requestContent'],
      claimContent: json['claimContent'] ?? '',
      estimatedValue: json['estimatedValue'],
      actualValue: json['actualValue'] ?? 0,
      refusalReason: json['refusalReason'] ?? '',
      createdDate: DateTime.parse(json['createdDate']),
      imageURL: List<String>.from(json['imageURL']),
      receiptImageURL: List<String>.from(json['receiptImageURL'] ?? []),
      repairState: RepairState.values.firstWhere(
            (e) => e.toString().split('.').last == json['repairState'],
        orElse: () => RepairState.NONE,
      ),
    );
  }
}