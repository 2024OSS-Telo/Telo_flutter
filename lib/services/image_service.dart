import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../const/backend_url.dart';
import '../const/image_path.dart';

class ImageService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(XFile image) async {
    String fileName =
        '${image.path.split('/').last.split('.').first}_${DateTime.now().millisecondsSinceEpoch.toString()}.${image.path.split('/').last.split('.').last}';

    try {
      Reference storageRef = _storage.ref().child('$IMAGE_PATH/$fileName');
      UploadTask uploadTask = storageRef.putFile(
        File(image.path),
      );
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      throw Exception('이미지 업로드에 실패했습니다: $e');
    }
  }
}
