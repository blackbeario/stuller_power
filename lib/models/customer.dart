import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String main;
  final String mobile;

  Customer({ this.id, this.firstName, this.lastName, this.email, this.main, this.mobile });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Customer(
      id: doc.documentID,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      main: data['main'] ?? '',
      mobile: data['mobile'] ?? '',
    );
  }
}


class CustomerLocation {
  final String id;
  final bool billing;
  final String area;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipcode;
  // final List position;

  CustomerLocation({ this.id, this.billing, this.area, this.name, this.address, this.city, this.state, this.zipcode });

  factory CustomerLocation.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    
    return CustomerLocation(
      id: doc.documentID,
      billing: data['billing'] ?? true,
      area: data['area'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipcode: data['zipcode'] ?? '',
      // position: data['position'] ?? ''
    );
  }
}


class CustomerMarker {
  final String id;
  final List position;

  CustomerMarker({ this.id, this.position });

  factory CustomerMarker.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return CustomerMarker(
      id: doc.documentID,
      position: data['position'] ?? '',
    );
  }
}