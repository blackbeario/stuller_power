// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './models/customer.dart';
import './db_service.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';

class LocationsList extends StatelessWidget {
  final db = DatabaseService();
  
  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<Location>>(context);
    var user = Provider.of<FirebaseUser>(context);

    if (locations == null) {
      return Flexible(
        flex: 1,
        fit: FlexFit.tight,
        child: Column(
          children: <Widget> [
            Text('No locations. Add one for this customer.'),
          ],
        ),
      );
    }
    else {
      return ListView(
        shrinkWrap: true,
        children: locations.map((location) {
          return Dismissible(
            direction: DismissDirection.endToStart,
            key: Key(location.id),
            onDismissed: (direction) {
              DatabaseService().removeLocation(user, location.id);
            },
            child: Card(
              margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text(location.name.toUpperCase()),
                      subtitle: Text(location.address),
                      // onTap: () => ,
                    ),
                  ],
                ),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(color: Colors.red), 
              child: Align(
                alignment: Alignment.centerRight, 
                child: Icon(Icons.delete, color: Colors.white, size: 40),
              ),
            ),
          );
        }).toList(),
      );
    }
  }
}

class CustomerList extends StatelessWidget {
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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


class Customers extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var customers = Provider.of<List<Customer>>(context);
    // var user = Provider.of<FirebaseUser>(context);
    if (customers == null) {
      return Center(
        child: CupertinoActivityIndicator(
          animating: true,
        )
      );
    }
    else return ListView(
      shrinkWrap: true,
      children: customers.map((customer) {
        return Material(
          // margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: Container(
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
              auth.signOut();
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
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(20.0),
        child: Container(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.info),
                  subtitle:  Text('${widget.customer.email}'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

