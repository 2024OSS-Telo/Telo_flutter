import 'package:dio/dio.dart';

import '../const/key.dart';

class AddressService {
  final Dio _dio = Dio();

  Future<List<String>> fetchAddressSuggestions(String query) async {
    try {
      final response = await _dio.get(
        'https://dapi.kakao.com/v2/local/search/address.json',
        queryParameters: {'query': query},
        options: Options(
          headers: {'Authorization': kakaoRestAppKey},
        ),
      );

      if (response.statusCode == 200) {
        List<String> addresses = [];
        for (var item in response.data['documents']) {
          addresses.add(item['address_name']);
        }
        return addresses;
      } else {
        throw Exception('Failed to load addresses');
      }
    } catch (error) {
      print('Error fetching addresses: $error');
      return [];
    }
  }
}