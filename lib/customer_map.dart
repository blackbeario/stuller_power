import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
// import './models/user.dart';
import './db_service.dart';
// import './locations_list.dart';
// import 'package:rxdart/rxdart.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';


class CustomerMap extends StatefulWidget {
  CustomerMap({Key key}) : super(key: key);
  _CustomerMapState createState() => _CustomerMapState();
}

class _CustomerMapState extends State<CustomerMap> {
  GoogleMapController mapController;
  // Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  // Completer<GoogleMapController> _controller = Completer();
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  // BehaviorSubject<double> radius = BehaviorSubject.seeded(100.0);
  // Stream<dynamic> query;
  // StreamSubscription subscription;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
  }

  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    // var radius = 100;
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(35.31873, -82.46095),
              zoom: 10
            ),
            myLocationEnabled: true,
            mapType: MapType.normal,
            compassEnabled: true,
            onMapCreated: _onMapCreated,
            markers: Set.from(allMarkers),
            // onCameraMove: _startQuery(),
          ),
          Positioned(
            top: 0,
            left: 0,
            width: 60,
            child: FlatButton(
              child: Icon(Icons.pin_drop, color: Colors.black),
              onPressed: _addGeoPoint
            ),
          )
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _startQuery();
    });
  }


  _startQuery() async {
    // Get the location of the current user.
    // var pos = await location.getLocation();
    // double lat = pos.latitude;
    double lat = 35.31873;
    // double lng = pos.longitude;
    double lng = -82.46095;

    // Sets a point for the current user location
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // Stream of customers list
    var customers = Provider.of<List<Customer>>(context);

    customers.forEach((Customer customer) {
      var ref = firestore.collection('customers').document(customer.id).collection('locations');
    
      double radius = 50;
      String field = 'position';

      Stream<List<DocumentSnapshot>> stream = geo.collection(collectionRef: ref).within(center: center, radius: radius, field: field);

      stream.listen((List<DocumentSnapshot> documentList) {
        _updateMarkers(documentList);
      });
    });
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document.data['position']['geopoint'];
      String address = document.data['address'];
      _addMarker(point.latitude, point.longitude, address);
    });
  }

  void _addMarker(double lat, double lng, String address) {
    setState(() {
      allMarkers.add(
        Marker (
          draggable: false,
          markerId: MarkerId (address),
          position: LatLng (lat, lng),
          infoWindow: InfoWindow(
            title: address
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }






  // Adds a new location for the current user.
  Future<DocumentReference> _addGeoPoint() async {
    var user = Provider.of<FirebaseUser>(context);
    Location location = new Location();
    Geoflutterfire geo = Geoflutterfire();
    var pos = await location.getLocation();
    GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
    return firestore.collection('users').document(user.uid).collection('locations').add({ 
      'position': point.data,
    });
  }

  // Gets the location of the current user.
  // We'll need this for the technicians later.
  // _animateToUser() async {
  //   var pos = await location.getLocation();
  //   mapController.animateCamera(CameraUpdate.newCameraPosition(
  //     CameraPosition(
  //       target: LatLng(pos.latitude,pos.longitude),
  //       zoom: 17,
  //     )
  //   ));
  // }

  @override
  dispose() {
    // subscription.cancel();
    super.dispose();
  }
}