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

class LandlordHomePage extends StatelessWidget {
  final VoidCallback onSignOut;

  const LandlordHomePage({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: LandlordHeaderHome(), body: LandlordBodyHome(onSignOut: onSignOut)));
  }
}

class LandlordHeaderHome extends StatelessWidget implements PreferredSizeWidget {
  const LandlordHeaderHome({super.key});

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

class LandlordBodyHome extends StatelessWidget {
  final VoidCallback onSignOut;

  const LandlordBodyHome({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final buildingProvider =
        Provider.of<BuildingProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      buildingProvider.initializeData(MemberService()).then((_) {
        buildingProvider.filterAvailableBuildings();
      });
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
                top: 20,
                left: 20,
                right: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    "임대 가능 건물",
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              Positioned(
                top: 80,
                left: 20,
                right: 20,
                bottom: 20,
                child: Consumer<BuildingProvider>(
                  builder: (context, buildingProvider, child) {
                    if (buildingProvider.filteredBuildings.isEmpty) {
                      return const Center(
                        child: Text(
                          "등록된 건물이 없습니다. \n 건물 탭에서 건물을 등록해 주세요.",
                          style: TextStyle(fontSize: 16.0, color: GRAY_COLOR),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: buildingProvider.filteredBuildings.length,
                      itemBuilder: (context, index) {
                        Building building =
                        buildingProvider.filteredBuildings[index];
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
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 1.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: LIGHT_GRAY_COLOR),
          borderRadius: BorderRadius.circular(13.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              child: Image.network(
                building.imageURL.first,
                width: 100.0,
                height: 120.0,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    building.buildingName,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Row(
                    children: [
                      const Icon(Icons.apartment,
                          size: 12.0, color: Colors.black),
                      const SizedBox(width: 5.0),
                      Text(
                        '임대 가능: ${building.numberOfHouseholds - building.numberOfRentedHouseholds} 건',
                        style: const TextStyle(
                            fontSize: 12.0, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '최근 공지: ',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: building.notice != null && building.notice!.isNotEmpty
                              ? building.notice
                              : '등록된 공지가 없습니다',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: building.notice != null && building.notice!.isNotEmpty
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class TenantHomePage extends StatelessWidget {
  final VoidCallback onSignOut;

  const TenantHomePage({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            appBar: TenantHeaderHome(), body: TenantBodyHome(onSignOut: onSignOut)));
  }
}

class TenantHeaderHome extends StatelessWidget implements PreferredSizeWidget {
  const TenantHeaderHome({super.key});

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

class TenantBodyHome extends StatelessWidget {
  final VoidCallback onSignOut;

  const TenantBodyHome({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
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

            ],
          ),
        ),
      ],
    );
  }
}