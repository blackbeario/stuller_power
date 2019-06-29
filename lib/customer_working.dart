import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
import './db_service.dart';
import './locations_list.dart';
import './customer_map.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class Customers extends StatefulWidget {
  const Customers({Key key}) : super(key: key);

  @override
  _CustomersState createState() => _CustomersState();
}

class _CustomersState extends State<Customers> {
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      resizeToAvoidBottomInset: true,
      navigationBar: CupertinoNavigationBar(
        middle: Text('Customers'),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: CustomerMap(
              initialPosition: const LatLng(35.31873, -82.46095),
              mapController: _mapController
            ),
            flex: 2,
          ),
          Flexible(
            flex: 3,
            child: CustomerList(mapController: _mapController,),
          ),
        ],
      ),
    );
  }
}

// Creates the Customer ListTiles, etc for the CustomerList
class CustomerList extends StatelessWidget {
  CustomerList({
    Key key,
    @required this.mapController,
  }) : super(key: key);

  final auth = FirebaseAuth.instance;
  final db = DatabaseService();
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    var customers = Provider.of<List<Customer>>(context);

    if (customers == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    return ListView(
      shrinkWrap: true,
      children: customers.map((customer) {
        return StreamProvider<List<CustomerLocation>>.value(
          // Only show the main location in this list.
          // Multiple locations will be shown on detail screen.
          stream: db.primarylocation(customer.id),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.0),
            child: Container(
              color: CupertinoColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomerLoc(customer: customer, mapController: mapController),
                ],
              ),
            )
          )
        );
      }).toList(),
    );
  }
}

class CustomerLoc extends StatelessWidget {
  const CustomerLoc({
    Key key,
    @required this.customer,
    @required this.mapController,
  }) : super(key: key);

  final Customer customer;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<CustomerLocation>>(context);
    if (locations == null) {
      return Center(
        child: Text('Loading...')
      );
    }
    return ListView(
      shrinkWrap: true,
      children: locations.map((location) {
        return InkWell(
          onTap: () {
            _goToLocation(mapController, location);
          },
          onDoubleTap: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (context) {
                return CustomerDetails(customer);
              }),
            );
          },
          // Call the customer
          onLongPress: () {_requestPop(customer, context);},
          child: ListTile(
            dense: true,
            // TODO: Change leading to area icon/color
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
            leading: Icon(Icons.person_pin_circle, color: Colors.red, size: 36),
            title: Text(customer.firstName + ' ' + customer.lastName),
            subtitle: Text(customer.email),
            trailing: Icon(Icons.phone, color: Colors.green),
          ),
        );
      }).toList(),
    );
  }

  void _goToLocation(mapController, location) async {
    double lat = location.position['geopoint'].latitude;
    double long = location.position['geopoint'].longitude;
    final controller = await mapController.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, long), 16));
  }

  Future<bool> _requestPop(customer, BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Call ' + customer.firstName + ' ' + customer.lastName + '?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Okay'),
            isDestructiveAction: true,
            onPressed: () {
              bool hasMain = customer.main != '';
              var phone = hasMain ? customer.main : customer.mobile;
              UrlLauncher.launch("tel:" + phone);
              Navigator.pop(context, 'Discard');
            }
          ),
          CupertinoDialogAction(
            child: Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          ),
        ],
      );
    });
    return Future.value(false);
  }
}


// Customer Details screen
class CustomerDetails extends StatefulWidget {
  final Customer customer;
  const CustomerDetails(this.customer);

  @override
  _CustomerDetailsState createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  final db = DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.customer.firstName}' + ' ' + '${widget.customer.lastName}'),
        trailing: CupertinoButton(
          child: Text('Edit', style: TextStyle(fontSize: 12)),
          onPressed: () => _editCustomer(context)
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: Stack(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  StreamProvider<List<CustomerLocation>>.value(
                    stream: db.streamlocations(widget.customer.id),
                    child: Locations(customer: widget.customer),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

   Future<bool> _editCustomer(BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Edit Customer?'),
        content: Text('Are you sure you really want to update this customer?' 
          + ' This will affect all instances of this customer on all devices immediately.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Yes'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, 'Discard');
            }
          ),
          CupertinoDialogAction(
            child: Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context, 'Cancel');
            },
          ),
        ],
      );
    });
    return Future.value(false);
  }
}