import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _role = 'customer'; // customer, seller, delivery

  // General user profile info (synced across screens)
  String _userName = "Eng. Ahmed Mohamed";
  String _userEmail = "ahmed.dev@gmail.com";
  String _userPhone = "+2001012345678";

  // Seller info
  String? _storeName;
  String? _sellerPhone;
  String? _storeAddress;
  String? _businessCategory;
  String? _sellerEmail;

  // Delivery info
  String? _deliveryName;
  String? _deliveryPhone;
  String? _vehicleType;
  String? _licensePlate;
  String? _deliveryEmail;

  UserRoleProvider() {
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      String uid = userCredential.user!.uid;

      // Listen to real-time changes of the user profile document in Firestore
      _firestore.collection('users').doc(uid).snapshots().listen((snapshot) async {
        if (snapshot.exists) {
          final data = snapshot.data();
          _role = data?['role'] ?? 'customer';
          _userName = data?['userName'] ?? "Eng. Ahmed Mohamed";
          _userEmail = data?['userEmail'] ?? "ahmed.dev@gmail.com";
          _userPhone = data?['userPhone'] ?? "+2001012345678";

          _storeName = data?['storeName'];
          _sellerPhone = data?['sellerPhone'];
          _storeAddress = data?['storeAddress'];
          _businessCategory = data?['businessCategory'];
          _sellerEmail = data?['sellerEmail'];

          _deliveryName = data?['deliveryName'];
          _deliveryPhone = data?['deliveryPhone'];
          _vehicleType = data?['vehicleType'];
          _licensePlate = data?['licensePlate'];
          _deliveryEmail = data?['deliveryEmail'];

          notifyListeners();
        } else {
          // Document does not exist, initialize it with default values
          await _firestore.collection('users').doc(uid).set({
            'role': _role,
            'userName': _userName,
            'userEmail': _userEmail,
            'userPhone': _userPhone,
          });
        }
      });
    } catch (e) {
      debugPrint("Error initializing user in Firebase: $e");
    }
  }

  String get role => _role;

  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;

  String? get storeName => _storeName;
  String? get sellerPhone => _sellerPhone;
  String? get storeAddress => _storeAddress;
  String? get businessCategory => _businessCategory;
  String? get sellerEmail => _sellerEmail;

  String? get deliveryName => _deliveryName;
  String? get deliveryPhone => _deliveryPhone;
  String? get vehicleType => _vehicleType;
  String? get licensePlate => _licensePlate;
  String? get deliveryEmail => _deliveryEmail;

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _userName = name;
    _userEmail = email;
    _userPhone = phone;
    notifyListeners();

    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'userName': name,
        'userEmail': email,
        'userPhone': phone,
      });
    } catch (e) {
      debugPrint("Error updating user profile: $e");
    }
  }

  Future<void> registerAsSeller({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String category,
  }) async {
    _role = 'seller';
    _storeName = name;
    _sellerEmail = email;
    _sellerPhone = phone;
    _storeAddress = address;
    _businessCategory = category;
    notifyListeners();

    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'seller',
        'storeName': name,
        'sellerEmail': email,
        'sellerPhone': phone,
        'storeAddress': address,
        'businessCategory': category,
      });
    } catch (e) {
      debugPrint("Error registering as seller: $e");
    }
  }

  Future<void> registerAsDelivery({
    required String name,
    required String email,
    required String phone,
    required String vehicle,
    required String plate,
  }) async {
    _role = 'delivery';
    _deliveryName = name;
    _deliveryEmail = email;
    _deliveryPhone = phone;
    _vehicleType = vehicle;
    _licensePlate = plate.isEmpty ? null : plate;
    notifyListeners();

    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'delivery',
        'deliveryName': name,
        'deliveryEmail': email,
        'deliveryPhone': phone,
        'vehicleType': vehicle,
        'licensePlate': plate.isEmpty ? FieldValue.delete() : plate,
      });
    } catch (e) {
      debugPrint("Error registering as delivery: $e");
    }
  }

  Future<void> resetToCustomer() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'customer',
        'storeName': FieldValue.delete(),
        'sellerPhone': FieldValue.delete(),
        'storeAddress': FieldValue.delete(),
        'businessCategory': FieldValue.delete(),
        'sellerEmail': FieldValue.delete(),
        'deliveryName': FieldValue.delete(),
        'deliveryPhone': FieldValue.delete(),
        'vehicleType': FieldValue.delete(),
        'licensePlate': FieldValue.delete(),
        'deliveryEmail': FieldValue.delete(),
      });
    } catch (e) {
      debugPrint("Error resetting user to customer: $e");
    }
  }
}

