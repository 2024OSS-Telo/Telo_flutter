import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telo/const/colors.dart';
import 'package:telo/main.dart';
import 'package:telo/main.dart';
import 'package:telo/screens/notification_page.dart';
import 'package:telo/screens/repair/repair_list_page.dart';

import '../models/building_model.dart';
import '../provider/building_provider.dart';
import '../services/member_service.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onSignOut;

  const HomePage({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: HeaderHome(), body: BodyHome(onSignOut: onSignOut)));
  }
}

class HeaderHome extends StatelessWidget implements PreferredSizeWidget {
  const HeaderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MAIN_COLOR,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            child: Icon(
              Icons.notifications,
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class BodyHome extends StatelessWidget {
  final VoidCallback onSignOut;

  const BodyHome({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final buildingProvider = Provider.of<BuildingProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildingProvider.initializeData(MemberService());
    });

    return Column(
      children: [
        Flexible(
          flex: 2,
          child: Container(
            color: MAIN_COLOR,
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.logout),
                color: Colors.white,
                onPressed: onSignOut,
              ),
            ),
          ),
        ),
        Flexible(
            flex: 8,
            child: Stack(
              children: [
                Container(
                  color: MAIN_COLOR,
                ),
                Container(
                    decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                )),
                Positioned(
                  top: 20, // 텍스트의 Y축 위치
                  left: 20, // 텍스트의 X축 위치
                  right: 20,
                  bottom: 20,
                  child: Consumer<BuildingProvider>(
                    builder: (context, buildingProvider, child) {
                      if (buildingProvider.filteredBuildings.isEmpty) {
                        return const Center(
                          child: Text(
                            "등록된 건물이 없습니다",
                            style: TextStyle(fontSize: 16.0, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: buildingProvider.filteredBuildings.length,
                        itemBuilder: (context, index) {
                          Building building = buildingProvider.filteredBuildings[index];
                          return _buildingCard(building);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
        ),
      ],
    );
  }


  Widget _buildingCard(Building building) {
    return GestureDetector(
      onTap: () {
        // 빌딩 카드 클릭 시 동작 추가
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: LIGHT_GRAY_COLOR),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/image/buildingIMGtest.png',
                width: 80.0,
                height: 80.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    building.buildingName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    building.buildingAddress,
                    style: TextStyle(fontSize: 12.0, color: DARK_MAIN_COLOR),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const Icon(Icons.apartment, size: 12.0, color: Colors.black),
                      const SizedBox(width: 5.0),
                      Text(
                        '임대 완료: ${building.numberOfRentedHouseholds} 건',
                        style: const TextStyle(fontSize: 12.0, color: Colors.black),
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        '임대 가능: ${building.numberOfHouseholds - building.numberOfRentedHouseholds} 건',
                        style: const TextStyle(fontSize: 12.0, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    building.notice ?? '공지를 등록해보세요',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: building.notice == null ? Colors.grey : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
