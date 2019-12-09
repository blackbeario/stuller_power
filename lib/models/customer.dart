import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String main;
  final String mobile;
  final String notes;
  final List<String> jobs;
  final List<String> locations;

  Customer({ this.id, this.firstName, this.lastName, this.email, this.main, this.mobile, this.notes, this.jobs, this.locations });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Customer(
      id: doc.documentID,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      main: data['main'] ?? '',
      mobile: data['mobile'] ?? '',
      notes: data['notes'] ?? '',
      jobs: data['jobs'] != null ? List.from(data['jobs']) : null,
      locations: data['jobs'] != null ? List.from(data['jobs']) : null
    );
  }

  Map<String, dynamic> toJson() =>
    {
      'firstName' : firstName,
      'lastName' : lastName,
      'email' : email,
      'main' : main,
      'mobile' : mobile,
      'notes' : notes,
      'jobs' : jobs,
      'locations' : locations
    };
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
      address: data['address'] ?? 'Address unknown',
      city: data['city'] ?? 'no city provided',
      state: data['state'] ?? '',
      zipcode: data['zipcode'] ?? '',
      position: data['position'] ?? null
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
  final String wifi;

  Generator({ this.airFilter, this.battery, this.exerciseTime, 
  this.model, this.oilFilter, this.serial, this.sparkPlugs, this.transferLocation,
  this.transferSerial, this.warranty, this.wifi
  });

  factory Generator.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;

    return Generator(
      airFilter: data['air filter'] ?? '',
      battery: data['battery'] != null ? DateTime.fromMillisecondsSinceEpoch(data['battery']) : null,
      exerciseTime: data['exercise time'] ?? '',
      model: data['model'] ?? '',
      oilFilter: data['oil filter'] ?? '',
      serial: data['serial'] ?? '',
      sparkPlugs: data['spark plugs'] ?? '',
      transferLocation: data['xfer location'] ?? '',
      transferSerial: data['xfer serial'] ?? '',
      warranty: data['warranty'] ?? '',
      wifi: data['wifi'] ?? '',
    );
  }
}