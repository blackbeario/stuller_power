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
  final Map position;

  CustomerLocation({ this.id, this.billing, this.area, this.name, this.address, this.city, this.state, this.zipcode, this.position });

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
      position: data['position'] ?? ''
    );
  }
}


class Position {
  final String geohash;
  final GeoPoint geopoint;

  Position({ this.geohash, this.geopoint });

  factory Position.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    
    return Position(
      geohash: data['geohash'] ?? '',
      geopoint: data['geopoint'] ?? ''
    );
  }
}


class Generator {
  final String airFilter;
  final DateTime battery;
  final String exerciseTime;
  final String model;
  final String oilFilter;
  final String serial;
  final String sparkPlugs;
  final String transferLocation;
  final String transferSerial;
  final String warranty;
  final bool wifi;

  Generator({ this.airFilter, this.battery, this.exerciseTime, 
  this.model, this.oilFilter, this.serial, this.sparkPlugs, this.transferLocation,
  this.transferSerial, this.warranty, this.wifi
  });

  factory Generator.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Generator(
      airFilter: data['airFilter'] ?? '',
      battery: data['battery'] != null ? DateTime.fromMillisecondsSinceEpoch(data['battery']) : null,
      exerciseTime: data['exerciseTime'] ?? '',
      model: data['model'] ?? '',
      oilFilter: data['oilFilter'] ?? '',
      serial: data['serial'] ?? '',
      sparkPlugs: data['sparkPlugs'] ?? '',
      transferLocation: data['transferLocation'] ?? '',
      transferSerial: data['transferSerial'] ?? '',
      warranty: data['warranty'] ?? '',
      wifi: data['wifi'] ?? false,
    );
  }
}