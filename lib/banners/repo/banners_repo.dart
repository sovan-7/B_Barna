import 'dart:typed_data';
import 'package:bbarna/banners/model/banners_model.dart';
import 'package:bbarna/resources/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BannersRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Reference storageReference = FirebaseStorage.instance.ref();

  /// Returns the new document's id.
  ///
  /// It used to hand back the `DocumentReference` itself, which no caller
  /// wanted and which — being a sealed Firestore type — no test could fake.
  Future<String> addBanner(BannersModel bannersModel) async {
    final DocumentReference<Map<String, dynamic>> doc =
        await _firestore.collection(banners).add(bannersModel.toMap());
    return doc.id;
  }

  Future<List<BannersModel>> getBannersList() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(banners).get();
    return snapshot.docs
        .map((docSnapshot) => BannersModel.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

  /// Uploads [image] and points the banner document at it.
  ///
  /// Throws on failure rather than swallowing the error into a snackbar.
  /// It used to catch everything here and return normally, so the caller
  /// went on to report "Banners uploaded successfully" over the top of the
  /// failure message and left a document behind with no image in it.
  Future<void> uploadBannerImage(Uint8List image, String bannerId) async {
    final Reference referenceDirImages = storageReference.child("images");
    final int timeStamp = DateTime.now().millisecondsSinceEpoch;
    final Reference referenceImageToUpload =
        referenceDirImages.child("${timeStamp}_img");

    final metadata = SettableMetadata(contentType: "image/jpeg");
    await referenceImageToUpload.putData(image, metadata);
    final String imageUrl = await referenceImageToUpload.getDownloadURL();
    await _firestore
        .collection(banners)
        .doc(bannerId)
        .update({"banner_image": imageUrl});
  }

  Future<void> deleteBanner(String bannerId) async {
    await _firestore.collection(banners).doc(bannerId).delete();
  }
}
