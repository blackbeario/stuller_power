// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
import './db_service.dart';
import './locations_list.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';

class CustomerList extends StatelessWidget {
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;

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
          StreamProvider<List<Customer>>.value(
            stream: db.streamCustomers(),
            child: Customers(),
          )
        ],
      ),
    );
  }
}

// Creates the Customer ListTiles, etc for the CustomerList
class Customers extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

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
    else return ListView(
      padding: EdgeInsets.all(10),
      shrinkWrap: true,
      children: customers.map((customer) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          child: Container(
            color: CupertinoColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    // TODO: show on map! :)
                    // _requestPop(customer, context);
                  },
                  onDoubleTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(builder: (context) {
                        return CustomerDetails(customer);
                      }),
                    );
                  },
                  onLongPress: () {_requestPop(customer, context);},
                  child: ListTile(
                    // TODO: Change leading to area icon/color.
                    leading: Icon(Icons.person_pin_circle, color: Colors.red, size: 42),
                    title: Text(customer.firstName + ' ' + customer.lastName),
                    subtitle: Text(customer.email),
                    trailing: Icon(Icons.phone, color: Colors.green),
                  ),
                ),            
                Divider()
              ],
            ),
          )
        );
      }).toList(),
    ); 
  }

  // Actions for Customer items
  Future<bool> _requestPop(customer, BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Call ' + customer.firstName + ' ' + customer.lastName + '?'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Okay'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, 'Discard');
              // auth.signOut();
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
    return new Future.value(false);
  }
}


// Obviously, the Customer Details screen
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
    // var customer = Provider.of<Customer>(context);
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
                  StreamProvider<List<Location>>.value(
                    stream: db.streamlocations(widget.customer.id),
                    child: Locations(),
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

