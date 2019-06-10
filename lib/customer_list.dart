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
    var user = Provider.of<FirebaseUser>(context);
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
        return Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(customer.id),
          onDismissed: (direction) {
            DatabaseService().removeLocation(user, customer.id);
          },
          child: Card(
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text(customer.firstName),
                    subtitle: Text(customer.lastName),
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