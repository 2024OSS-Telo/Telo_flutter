class Member {
  String memberID;
  String memberRealName;
  String memberNickName;
  String phoneNumber;
  String profile;
  String provider; // google, kakao
  String memberType; // landlord, tenant

  // 기본 생성자
  Member({
    required this.memberID,
    required this.memberRealName,
    required this.memberNickName,
    required this.phoneNumber,
    required this.profile,
    required this.provider,
    required this.memberType,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberID: json['memberID'] ?? '',
      memberRealName: json['memberRealName'] ?? '',
      memberNickName: json['memberNickName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      profile: json['profile'] ?? '',
      provider: json['provider'] ?? '',
      memberType: json['memberType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberID': memberID,
      'memberRealName': memberRealName,
      'memberNickName': memberNickName,
      'phoneNumber': phoneNumber,
      'profile': profile,
      'provider': provider,
      'memberType': memberType,
    };
  }
}
