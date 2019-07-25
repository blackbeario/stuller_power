// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './models/customer.dart';
import './services/db_service.dart';
// import 'package:mobile/ui/elements/cupertino_area_picker.dart';
import 'package:flutter/cupertino.dart';

class CustomerAddEdit extends StatefulWidget {
  final Customer customer;
  const CustomerAddEdit(this.customer);

  @override
  State<StatefulWidget> createState() => _CustomerAddEditState(customer);
}

class _CustomerAddEditState extends State<CustomerAddEdit>{
  final db = DatabaseService();
  final auth = FirebaseAuth.instance;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mainController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  _CustomerAddEditState(Customer customer);

  @override
  void initState() {
    super.initState();
      _firstNameController.text = widget.customer.firstName;
      _lastNameController.text = widget.customer.lastName;
      _mainController.text = widget.customer.main;
      _mobileController.text = widget.customer.mobile;
      _emailController.text = widget.customer.email;
      _notesController.text = widget.customer.notes;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mainController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String locid; bool billing; String address; String area; String city; String state; String zip;

  // Pass LocationForm child class text field values via callback.
  void callback(_locid, _billing, _address, _area, _city, _state, _zip) {
    setState(() {
      locid = _locid;
      billing = _billing;
      address = _address;
      area = _area;
      city = _city;
      state = _state;
      zip = _zip;
    });
  }

  String _validatePhoneNumber(String value) {
    // _formWasEdited = true;
    final RegExp phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(value))
      return '(###) ###-#### - Enter a US phone number.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text('${widget.customer.firstName}' + ' ' + '${widget.customer.lastName}'),
        trailing: CupertinoButton(
          child: Text('Save', style: TextStyle(fontSize: 12)),
          onPressed: () => _updateCustomer(context)
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(10),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // First Name input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'First name',
                  labelText: 'First name',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _firstNameController,
                keyboardType: TextInputType.text
              ),

              // Last Name input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Last name',
                  labelText: 'Last name',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _lastNameController,
                keyboardType: TextInputType.text
              ),

              // Email input
              TextField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onChanged: (text) => _customerAddEditBloc.firstNameSink.add(text),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Email',
                  labelText: 'Email',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).firstNameEmpty : null
                ),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress
              ),
              
              // Main phone input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onSaved: (text) => _customerAddEditBloc.phoneSink.add(text),
                validator: _validatePhoneNumber,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Main',
                  labelText: 'Main',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).phoneEmpty : null
                ),
                controller: _mainController,
                keyboardType: TextInputType.phone,
              ),

              // Cell input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                // onSaved: (text) => _customerAddEditBloc.phoneSink.add(text),
                validator: _validatePhoneNumber,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  labelText: 'Mobile',
                  hintText: 'Mobile',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).phoneEmpty : null
                ),
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              ),

              // Notes input
              TextFormField(
                minLines: 2,
                maxLines: 10,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                decoration: InputDecoration(
                  icon: Icon(Icons.note),
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  labelText: 'Notes',
                  hintText: 'Notes',
                ),
                controller: _notesController,
                keyboardType: TextInputType.multiline,
              ),

              // Add some space between sections
              SizedBox(height: 40),

              StreamProvider<List<CustomerLocation>>.value(
                stream: db.streamlocations(widget.customer.id),
                child: LocationWidget(customer: widget.customer, callback: callback),
              ),
            ]
          )
        ),
      ),
    );
  }

  Future<bool> _updateCustomer(BuildContext context) {
    showCupertinoDialog(context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Update Customer'),
        content: Text('This will immediately update this customer data.'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text('Confirm'),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context, 'Discard');
              db.updateCustomer(
                widget.customer.id, _firstNameController.text, _lastNameController.text, 
                _emailController.text, _mainController.text, _mobileController.text,
                _notesController.text
              );
              // db.updateLocation(
              //   widget.customer.id, billing, address, area, city, state, zip
              // );
              
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

class LocationWidget extends StatefulWidget {
  LocationWidget({
    Key key,
    this.callback,
    @required this.customer,
  }) : super(key: key);

  final Function callback;
  final Customer customer;
  final db = DatabaseService();

  @override
  State<StatefulWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {

  @override
  Widget build(BuildContext context) {
    var locations = Provider.of<List<CustomerLocation>>(context);

    if (locations == null) {
      return Center(
        child: Text('No locations. Add one for this customer.')
      );
    }

    return ListView(
      shrinkWrap: true,
      children: locations.map((location) {
        bool _billing = location.billing;
        if(locations.length == 1) {
          return LocationForm(location: location, billing: _billing, callback: widget.callback,);
        }
        return ExpansionTile(
          initiallyExpanded: false,
          title: Text(location.name.toUpperCase()),
          children: <Widget>[
            LocationForm(location: location, billing: _billing),
          ],
        );
      }).toList(),
    );
  }
}

class LocationForm extends StatefulWidget {
  LocationForm({
    Key key,
    this.callback,
    @required this.location,
    @required this.billing,
  }) : super(key: key);

  String locid; bool billing; String address; String area; String city; String state; String zip;
  final Function callback;
  final CustomerLocation location;

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.location.address;
    _cityController.text = widget.location.city;
    _stateController.text = widget.location.state;
    _zipcodeController.text = widget.location.zipcode;
  }

  void _billingChanged(bool value) {
    setState(() => widget.billing = value);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Area filter
            // DropdownButtonFormField(
            //   items: areas.map((String area) {
            //     return new DropdownMenuItem(
            //       value: area,
            //       child: new Text(area),
            //     );
            //   }).toList(),
            //   // onChanged: (newValue) {
            //   //   _customerAddEditBloc.areaSink.add(newValue);
            //   //   setState(() => _area = newValue);
            //   // },
            //   // This needs work to get saved value from Firebase.
            //   value: _area,
            //   decoration: InputDecoration(
            //     contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
            //     filled: true,
            //     fillColor: Colors.grey[200],
            //     hintText: 'Area', 
            //     // errorText: errorSnapshot.data == 0 ? Localization.of(context).areaEmpty : null),
            //   ),
            // ),

            // Billing
            CheckboxListTile(
              value: widget.billing,
              onChanged: (bool) =>
                _billingChanged,
                // widget.callback(
                //   widget.billing = widget.billing
                // );
              // },
              title: new Text('Billing Address?'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: CupertinoColors.activeBlue,
            ),

            // Address input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),                
              onEditingComplete: () {
                print(_addressController.text);
                widget.callback(
                  widget.address = _addressController.text
                );
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'Address',
                hintText: 'Address', 
                // errorText: errorSnapshot.data == 1 ? Localization.of(context).addressEmpty : null
              ),
              controller: _addressController,
            ),

            // City input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              onChanged: (text) =>
                widget.callback(
                  widget.address = _cityController.text
                ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'City',
                hintText: "City", 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).cityEmpty : null
              ),
              controller: _cityController,
            ),

            // State input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              onChanged: (text) => 
                widget.callback(
                  widget.address = _stateController.text
                ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'State',
                hintText: "State", 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).stateEmpty : null
                ),
              controller: _stateController,
            ),

            // Zipcode input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              onChanged: (text) =>
                widget.callback(
                  widget.address = _zipcodeController.text
                ),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'ZipCode',
                hintText: 'Zipcode', 
                // errorText: errorSnapshot.data == 0 ? Localization.of(context).zipcodeEmpty : null
              ),
              controller: _zipcodeController,
            ),
          ],
        ),
    );
  }
}