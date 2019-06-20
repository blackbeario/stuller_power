import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:location/location.dart';
import 'dart:async';
import './models/customer.dart';
import './models/user.dart';
import './models/job.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Future<Customer> getCustomer(String id) async {
    var snap = await _db.collection('customers').document(id).get();
    return Customer.fromFirestore(snap);
  }

  /// Get a stream of a single document
  Stream<Customer> streamCustomer(String id) {
    return _db
      .collection('customers')
      .document(id)
      .snapshots()
      .map((snap) => Customer.fromFirestore(snap));
  }

  /// Customers collection
  Stream<List<Customer>> streamCustomers() {
    var ref = _db.collection('customers');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  /// Locations subcollection
  Stream<List<CustomerLocation>> streamlocations(String id) {
    var ref = _db.collection('customers').document(id).collection('locations');
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => CustomerLocation.fromFirestore(doc)).toList());
  }

  /// Locations subcollection
  Stream<CustomerLocation> streamlocation(String cid, String lid) {
    return _db
      .collection('customers')
      .document(cid).collection('locations').document(lid)
      .snapshots()
      .map((snapshot) => CustomerLocation.fromFirestore(snapshot));
  }

  /// Jobs collection
  Stream<List<Job>> streamJobs(FirebaseUser user) {
    var ref = _db.collection('jobs').where('techID', isEqualTo: user.uid);
    return ref.snapshots().map((list) =>
      list.documents.map((doc) => Job.fromFirestore(doc)).toList());
  }

  Stream<User> streamUser(String id) {
    return _db
      .collection('users')
      .document(id)
      .snapshots()
      .map((snap) => User.fromMap(snap.data));
  }

  Future<void> createCustomer(FirebaseUser user) {
    return _db
      .collection('customers')
      .document(user.uid)
      .setData(
        {
          'firstName': 'Ima',
          'lastName': 'Newcustomer',
          'email': 'ima@newcustomer.com'
        },
      );
  }

  Future<void> addLocation(FirebaseUser user, dynamic location) {
    return _db
      .collection('customers')
      .document(user.uid)
      .collection('locations')
      .add(location);
  }

  Future<void> removeLocation(FirebaseUser user, String id) {
    return _db
      .collection('customers')
      .document(user.uid)
      .collection('locations')
      .document(id)
      .delete();
  }

  Future<void> removeJob(FirebaseUser user, String id) {
    return _db
      .collection('jobs')
      .document(id)
      .delete();
  }

  Future<void> updateDone(String id, bool done) async {
    var $now = DateTime.now();
    var ended = done ? $now.millisecondsSinceEpoch : null;
    return await _db.collection('jobs').document(id).updateData({'done': done, 'ended': ended});  
  }

  // Future<DocumentReference> addGeoPoint(FirebaseUser user) async {
  //   Location location = new Location();
  //   Geoflutterfire geo = Geoflutterfire();
  //   var pos = await location.getLocation();
  //   GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
  //   return _db.collection('users').document(user.uid).collection('locations').add({ 
  //     'position': point.data,
  //   });
  // }
}
