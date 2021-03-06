import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
// import 'package:location/location.dart';
import 'dart:async';
import '../models/customer.dart';
import '../models/user.dart';
import '../models/job.dart';

class DatabaseService {
  final Firestore _db = Firestore.instance;

  Future<Customer> getCustomer(String id) async {
    var snap = await _db.collection('customers').document(id).get();
    return Customer.fromFirestore(snap);
  }

  /// Get a stream of a single document.
  Stream<Customer> streamCustomer(String id) {
    return _db
        .collection('customers')
        .document(id)
        .snapshots()
        .map((snap) => Customer.fromFirestore(snap));
  }

  /// Customers collection stream for map and list.
  Stream<List<Customer>> streamCustomers() {
    var ref = _db.collection('customers');
    return ref.snapshots().map((list) =>
        list.documents.map((doc) => Customer.fromFirestore(doc)).toList());
  }

  /// Single customer location for map list screen.
  Stream<List<CustomerLocation>> primarylocation(String id) {
    var ref = _db
        .collection('customers')
        .document(id)
        .collection('locations')
        .limit(1);
    return ref.snapshots().map((list) => list.documents
        .map((doc) => CustomerLocation.fromFirestore(doc))
        .toList());
  }

  Future<CustomerLocation> getLocation(String id) async {
    var snap = await _db
        .collection('customers')
        .document(id)
        .collection('locations')
        .document('primary')
        .get();
    return CustomerLocation.fromFirestore(snap);
  }

  /// All customer locations, in case they have more than one.
  Stream<List<CustomerLocation>> streamlocations(String id) {
    var ref = _db
        .collection('customers')
        .document(id)
        .collection('locations')
        .orderBy('name');
    return ref.snapshots().map((list) => list.documents
        .map((doc) => CustomerLocation.fromFirestore(doc))
        .toList());
  }

  /// Jobs collection stream.
  Stream<List<Job>> streamJobs() {
    var ref = _db.collection('jobs').orderBy('scheduled');
    return ref.snapshots().map(
        (list) => list.documents.map((doc) => Job.fromFirestore(doc)).toList());
  }

  /// Jobs collection stream by user id.
  Stream<List<Job>> streamJobsByUser(FirebaseUser user) {
    var ref = _db
        .collection('jobs')
        .where('techID', isEqualTo: user.uid)
        .orderBy('scheduled');
    return ref.snapshots().map(
        (list) => list.documents.map((doc) => Job.fromFirestore(doc)).toList());
  }

  /// Stream an individual job.
  Stream<Job> getJob(String id) {
    return _db
        .collection('jobs')
        .document(id)
        .snapshots()
        .map((snap) => Job.fromFirestore(snap));
  }

  /// Jobs collection stream.
  // Stream<List<Job>> streamCustomerJobs(String id) {
  //   var ref = _db.collection('jobs').where('customer', isEqualTo: id).orderBy('scheduled');
  //   return ref.snapshots().map((list) =>
  //     list.documents.map((doc) => Job.fromFirestore(doc)).toList());
  // }

  /// Generator data per location.
  Future<Generator> getGenerator(String cid, String lid) async {
    var snap = await _db
        .collection('customers')
        .document(cid)
        .collection('locations')
        .document(lid)
        .collection('generator')
        .document('gen')
        .get();
    return Generator.fromFirestore(snap);
  }

  Stream<User> streamUser(String id) {
    return _db
        .collection('users')
        .document(id)
        .snapshots()
        .map((snap) => User.fromFirestore(snap.data));
  }

  /// Get the logged-in user data.
  Future<User> getUser(FirebaseUser user) async {
    var snap = await _db.collection('users').document(user.uid).get();
    return User.fromFirestore(snap);
  }

  /// Get an individual Technician data.
  Future<User> getTech(String id) async {
    var snap = await _db.collection('users').document(id).get();
    return User.fromFirestore(snap);
  }

  Future<void> createCustomer(FirebaseUser user) {
    return _db.collection('customers').document(user.uid).setData(
      {
        'firstName': 'Ima',
        'lastName': 'Newcustomer',
        'email': 'ima@newcustomer.com'
      },
    );
  }

  Future<void> addUpdateCustomer(String id, String firstName, String lastName,
      String email, String main, String mobile, String notes, List jobs
      // String locationName,
      // String locationAddress,
      // String locationArea,
      // String locationCity,
      // String locationState,
      // String locationZip,
      ) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('customers').document(id).setData({
      'updated': updated,
      'firstName': firstName,
      'lastName': lastName,
      'email': email ?? '',
      'main': main ?? '',
      'mobile': mobile ?? '',
      'notes': notes,
      'jobs': jobs
      // 'locations': {
      //   'primary': {
      //     'name': locationName,
      //     'address': locationAddress,
      //     'area': locationArea,
      //     'city': locationCity,
      //     'state': locationState,
      //     'zipcode': locationZip,
      //   }
      // }
    });
  }

  Future<void> updateJob(String id, String category, String customer,
      String description, String techID, String title, String notes) async {
    var $now = DateTime.now();
    var updated = $now.millisecondsSinceEpoch;
    return await _db.collection('jobs').document(id).updateData({
      'updated': updated,
      'category': category ?? '',
      'customer': customer ?? '',
      'description': description ?? '',
      'techID': techID ?? '',
      'title': title ?? '',
      'notes': notes
    });
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

  Future<void> updateLocation(String id, String address, String area,
      String city, String state, String zipcode) async {
    return await _db
        .collection('customers')
        .document(id)
        .collection('locations')
        .document('primary')
        .updateData({
      'address': address ?? '',
      'area': area ?? '',
      'city': city ?? '',
      'state': state ?? '',
      'zipcode': zipcode ?? ''
    });
  }

  Future<void> removeJob(FirebaseUser user, String id) {
    return _db.collection('jobs').document(id).delete();
  }

  Future<void> startJob(String id) async {
    var $now = DateTime.now().millisecondsSinceEpoch;
    return await _db
        .collection('jobs')
        .document(id)
        .updateData({'started': $now});
  }

  Future<void> updateDone(String id, bool done) async {
    var $now = DateTime.now();
    var ended = done ? $now.millisecondsSinceEpoch : null;
    return await _db
        .collection('jobs')
        .document(id)
        .updateData({'done': done, 'ended': ended});
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

  markerColor(String area) {
    switch (area) {
      case 'Cedar Mtn':
        return Colors.pink[200];
        break;
      case 'Flat Rock':
        return Colors.teal[300];
        break;
      case 'Crab Creek':
        return Colors.blue[300];
        break;
      case 'Cummings Cove':
        return Colors.red[300];
        break;
      case 'Hendersonville':
        return Colors.green[300];
        break;
      case 'Brevard':
        return Colors.teal[300];
        break;
      case 'Rutherfordton':
        return Colors.purple[300];
        break;
      case 'Fairview':
        return Colors.orange[300];
        break;
      case 'Lake Lure':
        return Colors.grey[300];
        break;
      case 'Fletcher':
        return Colors.brown[300];
        break;
      case 'Asheville':
        return Colors.amber[300];
        break;
      case 'Weaverville':
        return Colors.amber[700];
        break;
      case 'Horse Shoe':
        return Colors.red[700];
        break;
      case 'Etowah':
        return Colors.green[700];
        break;
      default:
    }
  }
}
