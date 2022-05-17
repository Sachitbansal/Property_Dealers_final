import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// https://petercoding.com/firebase/2022/02/16/how-to-model-your-firebase-data-class-in-flutter/

class Property {
  final String title,
      Price,
      address,
      bedRooms,
      number,
      construction,
      types,
      name,
      keywords,
      sizeUnit,
      landSize,
      other,
      bathRooms;

  Property({
    required this.title,
    required this.Price,
    required this.address,
    required this.bedRooms,
    required this.number,
    required this.construction,
    required this.types,
    required this.keywords,
    required this.sizeUnit,
    required this.landSize,
    required this.other,
    required this.buyRent,
    required this.bathRooms,
    required this.images,
    required this.name,
    this.isPublic,
    this.bookmark,
    this.facilities,
    this.docId,
  });
  final String? docId, facilities;
  final List images, buyRent;
  bool? isPublic, bookmark;

  Map<String, dynamic> toMap() {
    return {
      'buyRent': buyRent,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'sizeUnit': sizeUnit,
      'isPublic': isPublic,
      'construction': construction,
      'landSize': landSize,
      'keywords': keywords,
      'address': address,
      'name': name,
      'number': number,
      'types': types,
      'Price': Price,
      'title': title,
      'images': images,
      'other': other,
      'bookmark': bookmark,
    };
  }

  Property.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : docId = doc.id,
        name = doc.data()!["name"],
        title = doc.data()!["title"],
        Price = doc.data()!["Price"],
        facilities = doc.data()!["facilities"],
        address = doc.data()!["address"],
        bedRooms = doc.data()!["bedRooms"],
        number = doc.data()!["number"],
        construction = doc.data()!["construction"],
        types = doc.data()!["types"],
        keywords = doc.data()!["keywords"],
        sizeUnit = doc.data()!["sizeUnit"],
        landSize = doc.data()!["landSize"],
        other = doc.data()!["other"],
        buyRent = doc.data()!["buyRent"],
        bathRooms = doc.data()!["bathRooms"],
        images = doc.data()!["images"],
        bookmark = doc.data()!["bookmark"],
        isPublic = doc.data()!["isPublic"];
}

class DatabaseServices {
  final String? collectionId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addProperty(Property propertyData) async {
    await _db.collection(collectionId.toString()).add(propertyData.toMap());
  }

  updateProperty(Property propertyData) async {
    await _db
        .collection(collectionId.toString())
        .doc(propertyData.docId)
        .update(propertyData.toMap());
  }

  Future<List<Property>> retrieveProperties() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await _db.collection(collectionId.toString()).get();
    return snapshot.docs
        .map((docSnapshot) => Property.fromDocumentSnapshot(docSnapshot))
        .toList();
  }
}
