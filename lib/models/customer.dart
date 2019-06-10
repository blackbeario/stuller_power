import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Customer({ this.id, this.firstName, this.lastName, this.email });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Customer(
      id: doc.documentID,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
    );
  }
}


class Location {
  final String id;
  final bool billing;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipcode;
  final String phone;
  final String generatorId;

  Location({ this.id, this.billing, this.name, this.address, this.city, this.state, this.zipcode, this.phone, this.generatorId });

  factory Location.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    
    return Location(
      id: doc.documentID,
      billing: data['billing'] ?? true,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipcode: data['zipcode'] ?? '',
      phone: data['phone'] ?? '',
      generatorId: data['generatorId'] ?? '',
    );
  }
}
