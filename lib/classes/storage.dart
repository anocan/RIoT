import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riot/widgets/widgets.dart';

final FirebaseStorage storage = FirebaseStorage.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

class StoreData {
  Future<String> uploadImageToStorage(String fileName, Uint8List file) async {
    Reference ref = storage.ref().child(fileName);
    UploadTask uploadTask = ref.putData(file);
    print(await ref.putData(file).snapshot.ref.getDownloadURL());
    TaskSnapshot snapshot = await uploadTask;
    print("object");
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> saveData({required Uint8List file}) async {
    String resp = "error";
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      String imageUrl = await uploadImageToStorage(
          "userData/$userId/images/profilePicture", file);
      await updateUser(pp: imageUrl);
      resp = "success";
    } catch (e) {
      resp = e.toString();
    }
    return resp;
  }
}
