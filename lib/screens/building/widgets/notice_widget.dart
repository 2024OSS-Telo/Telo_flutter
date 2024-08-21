import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:telo/const/colors.dart';

import '../../../const/backend_url.dart';

class NoticeWidget extends StatefulWidget {
  final String buildingID;
  final String initialNotice;

  const NoticeWidget({
    super.key,
    required this.buildingID,
    required this.initialNotice,
  });

  @override
  NoticeWidgetState createState() => NoticeWidgetState();
}

class NoticeWidgetState extends State<NoticeWidget> {
  late TextEditingController _noticeController;
  final Dio _dio = Dio();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _noticeController = TextEditingController();
    _fetchNotice();
  }

  Future<void> _fetchNotice() async {
    try {
      final response =
          await _dio.get('$backendURL/api/buildings/${widget.buildingID}');
      if (response.statusCode == 200) {
        setState(() {
          _noticeController.text = response.data['notice'] ?? '';
          _isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항을 불러오는 데 실패했습니다')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공지사항을 불러오는 중 오류 발생')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotice() async {
    final notice = _noticeController.text;
    try {
      final response = await _dio.patch(
        '$backendURL/api/buildings/${widget.buildingID}/notice',
        data: {'notice': notice},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항이 업데이트되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('공지사항 업데이트 실패')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('공지사항 업데이트 중 오류 발생')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: VERY_LIGHT_GRAY_COLOR,
            borderRadius: BorderRadius.circular(10.0)

          ),
          child: Column(children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: DARK_GRAY_COLOR),
                SizedBox(width: 8),
                Text(
                  '공지사항',
                  style: TextStyle(fontSize: 16, color: DARK_GRAY_COLOR),
                ),
              ],
            ),
            SizedBox(height: 3),
            TextField(
              controller: _noticeController,
              maxLength: 200,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '공지사항을 등록해주세요',
                hintStyle: TextStyle(color: GRAY_COLOR),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: _updateNotice,
              icon: Icon(Icons.check_rounded),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _noticeController.clear();
                  _updateNotice();
                });
              },
              icon: Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
      ],
    );
  }
}
