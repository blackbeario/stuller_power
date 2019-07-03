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
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
  }

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "search"){
        _searchVisible = visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // var customers = Provider.of<List<Customer>>(context);
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
            child: CustomerList(mapController: _mapController)
          )
        ]
      ),
    );
  }
}


// Creates the Customer ListTiles, etc for the CustomerList
class CustomerList extends StatefulWidget {
  CustomerList({
    Key key,
    @required this.mapController,
  }) : super(key: key);

  final Completer<GoogleMapController> mapController;
  @override
  _CustomerListState createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  List<Customer> _customers = List();
  List<Customer> filteredCustomers = List();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,() {
      var customers = Provider.of<List<Customer>>(context);
      setState(() {
        _customers = customers;
        filteredCustomers = _customers;
      });
    });
  }

  // Resets customer list from child widget action.
  void callback(resetCustomers) {
    setState(() {
      _changed(false, "search");
      filteredCustomers = resetCustomers;
    });
  }

  bool _searchVisible = false;

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "search"){
        _searchVisible = visibility;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    if (filteredCustomers == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
          radius: 18.0,
        )
      );
    }
    return Container(
      decoration: new BoxDecoration(color: Colors.white),
      child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: ListView.separated(
            itemCount: filteredCustomers.length,
            shrinkWrap: true,
            separatorBuilder: (context, index) {
              return Divider(height: 0);
            },
            itemBuilder: (context, index) {
              if (index < filteredCustomers.length) {
                return CustomerTile(
                  callback: callback,
                  changed: _changed,
                  customers: _customers,
                  db: db,
                  filtered: filteredCustomers,
                  index: index,
                  lastItem: index == filteredCustomers.length -1,
                  customer: filteredCustomers[index],
                  mapController: widget.mapController,
                );
              }
              return Text('loading...');
            }
          ),
        ),

        _searchVisible ? new Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              flex: 11,
              child: CupertinoTextField(
                padding: EdgeInsets.all(10.0),
                expands: true,
                autofocus: true,
                minLines: null,
                maxLines: null,
                placeholder: " search",
                onChanged: (string) {
                  setState(() {
                    filteredCustomers = _customers
                      .where((customer) => (customer.firstName.toLowerCase()
                        .contains(string.toLowerCase()) ||
                        customer.lastName.toLowerCase().contains(string.toLowerCase())
                        || customer.email.toLowerCase().contains(string.toLowerCase())))
                      .toList();
                  });
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: new CupertinoButton(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(CupertinoIcons.clear, size: 44,),
                onPressed: () {
                  _changed(false, "search");
                  filteredCustomers = _customers;
                },
              ),
            )
          ]
        ) : Row(
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment.bottomRight,
                // color: Colors.yellow,
                child: CupertinoButton(
                  borderRadius: BorderRadius.zero,
                  padding: EdgeInsets.fromLTRB(340.0, 0, 20, 0),
                  // color: Colors.grey,
                  child: Icon(CupertinoIcons.search),
                  onPressed: () {
                    _changed(true, "search");
                  },
                ),
              ),
            ),
          ],
        ),
      ],
      ),
    );
  }
}

class CustomerTile extends StatefulWidget {
  CustomerTile({
    Key key,
    this.callback,
    this.changed,
    this.customers,
    this.db,
    this.filtered,
    this.index,
    this.lastItem,
    @required this.customer,
    @required this.mapController,
  }) : super(key: key);

  final Function callback;
  final changed;
  final List<Customer> customers;
  final db;
  List<Customer> filtered;
  final int index;
  final bool lastItem;
  final Customer customer;
  final Completer<GoogleMapController> mapController;

  @override
  _CustomerTileState createState() => _CustomerTileState();
}

class _CustomerTileState extends State<CustomerTile> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CustomerLocation>(
      future: widget.db.getLocation(widget.customer.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Material(
            child: ListTile(
              leading: Icon(Icons.error_outline, color: Colors.red),
              title: Text('Cannot get customer location'),
            ),
          );
        }
        else if (snapshot.hasData) {
          return Material(
            child: InkWell(
            onTap: () {
              _goToLocation(widget.mapController, snapshot.data.position);
              widget.callback(
                widget.filtered = widget.customers
              );
            },
              onDoubleTap: () async {
                widget.callback(
                  widget.filtered = widget.customers
                );
                await Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) {
                    return CustomerDetails(widget.customer);
                  }),
                );
              },
              // Call the customer
              onLongPress: () {_requestPop(widget.customer, context);},
              child: ListTile(
                dense: true,
                // TODO: Change leading to area icon/color
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                leading: Icon(Icons.person_pin_circle, color: Colors.red, size: 36),
                title: Text(widget.customer.firstName + ' ' + widget.customer.lastName),
                subtitle: Text(widget.customer.email),
                trailing: Icon(Icons.phone, color: Colors.green),
              ),
            ),
          );
        }
        else {
          return CupertinoActivityIndicator();
        }
      }
    );
  }

  void _goToLocation(mapController, location) async {
    double lat = location['geopoint'].latitude;
    double long = location['geopoint'].longitude;
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