import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Source
// https://petercoding.com/firebase/2022/02/16/how-to-model-your-firebase-data-class-in-flutter/

class Property {
  final String? id;
  final String name;
  final int age;
  final int salary;
  final List<String>? propertyTraits;
  Property(
      {this.id,
        required this.name,
        required this.age,
        required this.salary,
        this.propertyTraits});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'salary': salary,
      'propertyTraits': propertyTraits
    };
  }

  Property.fromDocumentSnapshot(DocumentSnapshot<Map<String, dynamic>> doc)
      : id = doc.id,
        name = doc.data()!["name"],
        age = doc.data()!["age"],
        salary = doc.data()!["salary"],
        propertyTraits = doc.data()!["propertyTraits"];
}

class DatabaseServices {
  final String? collectionId = FirebaseAuth.instance.currentUser?.uid;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  addProperty(Property propertyData) async {
    await _db.collection(collectionId.toString()).add(propertyData.toMap());
  }

  updateProperty(Property propertyData) async {
    await _db.collection(collectionId.toString()).doc(propertyData.id).update(propertyData.toMap());
  }

  Future<void> deleteProperty(String documentId) async {
    await _db.collection(collectionId.toString()).doc(documentId).delete();

  }

  Future<List<Property>> retrieveProperties() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await _db.collection(collectionId.toString()).get();
    return snapshot.docs
        .map((docSnapshot) => Property.fromDocumentSnapshot(docSnapshot))
        .toList();
  }

}

