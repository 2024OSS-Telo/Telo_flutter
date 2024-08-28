import 'package:flutter/cupertino.dart';

import '../models/repair_request_model.dart';
import '../services/member_service.dart';
import '../services/repair_request_service.dart';

class RepairRequestProvider with ChangeNotifier {
  final repairRequestService = RepairRequestService();
  List<RepairRequest> _repairRequests = [];

  List<RepairRequest> get repairRequests => _repairRequests;

  Future<void> initializeData(String memberID) async {
    try {
      _repairRequests.clear();
      _repairRequests = await repairRequestService.getRepairRequestList(memberID);
      notifyListeners();
    } catch (e) {
      print('수리 요청 목록 로딩 실패: $e');
    }
  }
}