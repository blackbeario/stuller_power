import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './services/db_service.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'customer_list.dart';

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
  MapType _currentMapType = MapType.normal;
  final Set<Marker> _markers = {};
  Location location = new Location();
  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  final db = DatabaseService();
  bool pressAttention = false;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
      pressAttention = !pressAttention;
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
          initialCameraPosition:
              CameraPosition(target: widget.initialPosition, zoom: 11),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: _currentMapType,
          compassEnabled: true,
          onMapCreated: _onMapCreated,
          markers: Set.from(_markers),
        ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: Align(
            alignment: Alignment(1, 0),
            child: Column(
              children: <Widget>[
                FlatButton(
                  padding: EdgeInsets.fromLTRB(0, 40, 40, 20),
                  onPressed: _animateToUser,
                  child: Icon(Icons.zoom_out_map,
                      color: pressAttention ? Colors.white : Colors.black),
                ),
                FlatButton(
                  padding: EdgeInsets.fromLTRB(0, 40, 40, 0),
                  onPressed: _onMapTypeButtonPressed,
                  child: Icon(Icons.map,
                      size: 20.0,
                      color: pressAttention ? Colors.white : Colors.black),
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
    // double lng = pos.longitude;

    // Setting lat/lng manually for testing
    double lat = 35.324767875803424;
    double lng = -82.54716329950985;

    // Sets a point for the current user location
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // Stream of customers list
    var customers = Provider.of<List<Customer>>(context);

    if (customers != null) {
      /// Get the locations for each customer.
      /// Shouldn't this be called with streamlocations()?
      customers.forEach((Customer customer) {
        // var ref = db.streamlocations(customer.id);
        var ref = firestore
            .collection('customers')
            .document(customer.id)
            .collection('locations');

        /// The radius affects how many markers are shown on the map respective to the location of the user.
        /// It does NOT affect how many customers are queried from Firestore, since
        /// we're calling streamCustomers() as a StreamProvider in main.dart.
        double radius = 50;
        String field = 'position';

        Stream<List<DocumentSnapshot>> stream = geo
            .collection(collectionRef: ref)
            .within(
                center: center, radius: radius, field: field, strictMode: true);

        stream.listen((List<DocumentSnapshot> documentList) {
          _updateMarkers(customer, documentList);
        });
      });
    }
  }

  void _updateMarkers(Customer customer, List<DocumentSnapshot> documentList) {
    documentList.forEach((DocumentSnapshot document) {
      GeoPoint point = document.data['position']['geopoint'];
      double distance = document.data['distance'];
      String area = document.data['area'];
      String address = document.data['address'];
      _addMarker(
          customer, point.latitude, point.longitude, area, address, distance);
    });
  }

  // Draws a canvas circle map marker with color
  Future<Uint8List> getBytesFromCanvas(
      int width, int height, Color _color) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint _paint = Paint()..color = _color;
    canvas.drawCircle(
        Offset(width / 3.33, height / 3.33), height / 3.33, _paint);
    final img = await pictureRecorder.endRecording().toImage(width, height);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data.buffer.asUint8List();
  }

  void _addMarker(Customer customer, double lat, double lng, String area,
      String address, double distance) async {
    final Uint8List markerIcon =
        await getBytesFromCanvas(40, 40, db.markerColor(area));
    final name = customer.firstName + ' ' + customer.lastName;
    final infoText =
        address + '\n' + 'Distance: ' + distance.toString() + ' mi';
    setState(() {
      _markers.add(
        Marker(
          draggable: false,
          markerId: MarkerId(address),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: name,
            snippet: infoText,
            onTap: () async {
              await Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) {
                  return StreamProvider<Customer>(
                    create: (context) => db.streamCustomer(customer.id),
                    child: CustomerDetails(customer.id),
                  );
                }),
              );
            },
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        ),
      );
    });
  }

  // Adds a new location for the current user.
  // Not needed now, but could be used for tracking techs later.
  // Future<DocumentReference> _addGeoPoint() async {
  //   var user = Provider.of<FirebaseUser>(context);
  //   Location location = new Location();
  //   Geoflutterfire geo = Geoflutterfire();
  //   var pos = await location.getLocation();
  //   GeoFirePoint point = geo.point(latitude: pos.latitude, longitude: pos.longitude);
  //   return firestore.collection('users').document(user.uid).collection('locations').add({
  //     'position': point.data,
  //   });
  // }

  // Gets the location of the current user.
  void _animateToUser() async {
    double lat = 35.31873;
    double lng = -82.46095;
    // var pos = await location.getLocation();
    final controller = await widget.mapController.future;
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 10,
    )));
  }

  @override
  dispose() {
    super.dispose();
  }
}
