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
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _billingController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  _CustomerAddEditState(Customer customer);

  @override
  void initState() {
    super.initState();
    bool $customer = widget.customer != null;
      _firstNameController.text = $customer ? widget.customer.firstName : '';
      _lastNameController.text = $customer ? widget.customer.lastName : '';
      _mainController.text = $customer ? widget.customer.main : '';
      _mobileController.text = $customer ? widget.customer.mobile : '';
      _emailController.text = $customer ? widget.customer.email : '';
      _notesController.text = $customer ? widget.customer.notes : '';
  }

  String locid; bool billing; String address; String area; String city; String state; String zip;

  // Pass LocationForm child class text field values via callback.
  void myCallback(String _address, String _area, String _city, String _state, String _zip) {
    setState(() {
      // _billingController.text = _billing;
      _addressController.text = _address;
      _areaController.text = _area;
      _cityController.text = _city;
      _stateController.text = _state;
      _zipController.text = _zip;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mainController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _billingController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
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
    var $name = widget.customer != null ? widget.customer.firstName + ' ' + widget.customer.lastName : 'New Customer';
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        middle: Text($name),
        trailing: CupertinoButton(
          child: Text('Save', style: TextStyle(fontSize: 12)),
          onPressed: () => _updateCustomer(widget.customer, context)
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
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'First name',
                  labelText: 'First name',
                ),
                controller: _firstNameController,
                keyboardType: TextInputType.text
              ),

              // Last Name input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Last name',
                  labelText: 'Last name',
                ),
                controller: _lastNameController,
                keyboardType: TextInputType.text
              ),

              // Email input
              TextFormField(
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                  hintText: 'Email',
                  labelText: 'Email',
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

              widget.customer != null ? 
              StreamProvider<List<CustomerLocation>>(
                builder: (context) => db.streamlocations(widget.customer.id),
                initialData: <CustomerLocation>[],
                child: LocationWidget(customer: widget.customer, callback: myCallback),
              ) : LocationForm(),
            ]
          )
        ),
      ),
    );
  }

  Future<bool> _updateCustomer(customer, BuildContext context) {
    var $id = widget.customer != null ? widget.customer.id : _firstNameController.text + ' ' + _lastNameController.text;
    Navigator.pop(context);
    db.addUpdateCustomer(
      $id, _firstNameController.text, _lastNameController.text, 
      _emailController.text, _mainController.text, _mobileController.text,
      _notesController.text
    );
    db.updateLocation(
      $id, _addressController.text, _areaController.text, 
      _cityController.text, _stateController.text, _zipController.text
    );
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
          return LocationForm(location: location, billing: _billing, callback: widget.callback);
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
    this.location,
    this.billing,
  }) : super(key: key);

  String locid; bool billing; String address; String area; String city; String state; String zip;
  final Function callback;
  final CustomerLocation location;

  @override
  _LocationFormState createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  final _addressLocController = TextEditingController();
  final _areaLocController = TextEditingController();
  final _cityLocController = TextEditingController();
  final _stateLocController = TextEditingController();
  final _zipcodeLocController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bool $location = widget.location != null;
    _addressLocController.text = $location ? widget.location.address : '';
    _areaLocController.text = $location ? widget.location.area : '';
    _cityLocController.text = $location ? widget.location.city : '';
    _stateLocController.text = $location ? widget.location.state : '';
    _zipcodeLocController.text = $location ? widget.location.zipcode : '';
  }

  void _billingChanged(bool value) {
    setState(() => widget.billing = value);
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
              value: widget.billing != null ? widget.billing : true,
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
            TextFormField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),                
              // onEditingComplete: () {
              //   print(_addressLocController.text);
              //   setState(() {
              //     widget.callback(
              //       widget.address = _addressLocController.text,
              //       // widget.callback(widget.address)
              //     );
              //   });
              // },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'Address',
                hintText: 'Address', 
              ),
              controller: _addressLocController,
              keyboardType: TextInputType.text
            ),

            // Area input
            TextField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),                
              // onEditingComplete: () {
              //   print(_areaLocController.text);
              //   setState(() {
              //     widget.callback(
              //       widget.area = _areaLocController.text
              //     );
              //   });
              // },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'Area',
                hintText: 'Area', 
              ),
              controller: _areaLocController,
            ),

            // City input
            TextFormField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) =>
              // setState(() {
              //   widget.callback(
              //     widget.city = _cityLocController.text
              //   );
              // }),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'City',
                hintText: "City", 
              ),
              controller: _cityLocController,
            ),

            // State input
            TextFormField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onChanged: (text) => 
              // setState(() {
              //   widget.callback(
              //     widget.state = _stateLocController.text
              //   );
              // }),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'State',
                hintText: "State", 
                ),
              controller: _stateLocController,
            ),

            // Zipcode input
            TextFormField(
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              // onFieldSubmitted: (text) =>
              // setState(() {
              //   widget.callback(
              //     widget.zip = _zipcodeLocController.text
              //   );
              // }),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 20),
                labelText: 'ZipCode',
                hintText: 'Zipcode', 
              ),
              controller: _zipcodeLocController,
            ),
          ],
        ),
    );
  }
}