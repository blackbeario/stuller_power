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
  const CustomerMap({
    Key key,
    @required this.initialPosition,
    @required this.mapController,
  }) : super(key: key);
  
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  _CustomerMapState createState() => _CustomerMapState();
}

class _CustomerMapState extends State<CustomerMap> {

  // final LatLng initialPosition;
  // final Completer<GoogleMapController> mapController;
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();

  final db = DatabaseService();

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onMapCreated(mapController) {
    setState(() {
      widget.mapController.complete(mapController);
      _startQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialPosition,
            zoom: 10
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: _currentMapType,
          compassEnabled: true,
          onMapCreated: _onMapCreated,
          markers: Set.from(_markers),
          // onCameraMove: _onCameraMove,
        ),
        Padding(
              padding: const EdgeInsets.all(0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: <Widget> [
                    FlatButton(
                      onPressed: _animateToUser,
                      child: Icon(Icons.center_focus_strong, color: Colors.black),
                    ),
                    FlatButton(
                      child: Icon(Icons.pin_drop, color: Colors.black),
                      onPressed: _addGeoPoint
                    ),
                    FlatButton(
                      onPressed: _onMapTypeButtonPressed,
                      child: const Icon(Icons.map, size: 20.0, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
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
      _markers.add(
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
  void _animateToUser() async {
    var pos = await location.getLocation();
    final controller = await widget.mapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(pos.latitude,pos.longitude),
        zoom: 17,
      )
    ));
  }

  @override
  dispose() {
    // subscription.cancel();
    super.dispose();
  }
}