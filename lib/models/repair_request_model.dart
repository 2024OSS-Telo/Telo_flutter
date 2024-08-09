enum RepairState{
  NONE, REFUSAL, APPROVAL, UNDER_REPAIR, CLAIM, COMPLETE
}

class RepairRequest {
  final String requestID;
  final String landlordID;
  final String tenantID;
  final String requestTitle;
  final String requestContent;
  final int estimateValue;
  final List<String> imageURL;
  RepairState repairState;

  RepairRequest({
    required this.requestID,
    required this.landlordID,
    required this.tenantID,
    required this.requestTitle,
    required this.requestContent,
    required this.estimateValue,
    required this.imageURL,
    required this.repairState
});

  Map<String, dynamic> toJson() {
    return {
      'requestID': requestID,
      'landlordID': landlordID,
      'tenantID': tenantID,
      'requestTitle': requestTitle,
      'requestContent': requestContent,
      'estimateValue': estimateValue,
      'imageURL': imageURL,
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
      estimateValue: json['estimateValue'],
      imageURL: List<String>.from(json['imageURL']),
      repairState: RepairState.values.firstWhere(
            (e) => e.toString().split('.').last == json['repairState'],
        orElse: () => RepairState.NONE,
      ),
    );
  }
}