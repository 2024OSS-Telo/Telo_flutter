import 'package:flutter/cupertino.dart';

import '../models/repair_request_model.dart';
import '../services/member_service.dart';
import '../services/repair_request_service.dart';

class RepairRequestProvider with ChangeNotifier {
  final repairRequestService = RepairRequestService();
  List<RepairRequest> _repairRequests = [];
  List<RepairRequest> _filteredRepairRequests = [];

  List<RepairRequest> get repairRequests => _repairRequests;
  List<RepairRequest> get filteredRepairRequests => _filteredRepairRequests;

  Future<void> initializeData(String memberID) async {
    try {
      _repairRequests.clear();
      _repairRequests = await repairRequestService.getRepairRequestList(memberID);
      getFilteredRepairRequests();
      notifyListeners();
    } catch (e) {
      print('수리 요청 목록 로딩 실패: $e');
    }
  }

  void getFilteredRepairRequests() {
    _filteredRepairRequests = _repairRequests.where((repairRequest) {
      return repairRequest.repairState == RepairState.UNDER_REPAIR ||
          repairRequest.repairState == RepairState.CLAIM;
    }).toList();
    notifyListeners();
  }
}