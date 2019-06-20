// import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './db_service.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';

class Locations extends StatelessWidget {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<CustomerLocation>>(context);

    if (locations == null) {
      return Center(
        child: Text('No locations. Add one for this customer.')
      );
    }
    else {
      return ListView(
        shrinkWrap: true,
        children: locations.map((location) {
          bool _billing = location.billing;

          if(locations.length == 1) {
            return Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.location_on, color: CupertinoColors.destructiveRed),
                  title: Text(location.address + '\n' + location.city + ' ' + location.state + ', ' + location.zipcode),
                ),
                ListTile(
                  leading: Icon(_billing ? CupertinoIcons.check_mark : CupertinoIcons.clear),
                  title: Text(_billing ? 'Primary Billing' : 'Do Not Bill'),
                ),
              ],
            );
          }
          else {
            return ExpansionTile(
              initiallyExpanded: true,
              key: PageStorageKey<CustomerLocation>(location),
              title: Text(location.name),
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.location_on, color: CupertinoColors.destructiveRed),
                  title: Text(location.address + '\n' + location.city + ' ' + location.state + ', ' + location.zipcode),
                ),
                ListTile(
                  leading: Icon(_billing ? CupertinoIcons.check_mark : CupertinoIcons.clear),
                  title: Text(_billing ? 'Primary Billing' : 'Do Not Bill'),
                ),
              ],
            );
          }
        }).toList(),
      );
    }
  }
}