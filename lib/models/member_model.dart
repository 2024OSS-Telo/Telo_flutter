class Member {
  String memberID;
  String memberName;
  String profile;
  String provider; // google, kakao
  String memberType; // landlord, tenant

  // 기본 생성자
  Member({
    required this.memberID,
    required this.memberName,
    required this.profile,
    required this.provider,
    required this.memberType,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberID: json['memberID'],
      memberName: json['memberName'],
      profile: json['profile'],
      provider: json['provider'],
      memberType: json['memberType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'memberID': memberID,
      'memberName': memberName,
      'profile': profile,
      'provider': provider,
      'memberType': memberType,
    };
  }
}
