import 'dart:io';

import 'package:contactapp/bloc/contact_bloc.dart';
import 'package:contactapp/constants/app_constants.dart';
import 'package:contactapp/model/app_phone.dart';
import 'package:contactapp/state/contact_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class AddOrUpdateContactPage extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ContactBloc _contactBloc;

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(10.0),
            height: 120,
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  child: FlatButton(
                      onPressed: () => {
                            Navigator.pop(context),
                            _contactBloc.getImage(ImageSource.gallery)
                          },
                      child: Text(
                        StringConstants.GALLERY,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
                Container(
                  width: double.infinity,
                  child: FlatButton(
                      onPressed: () => {
                            Navigator.pop(context),
                            _contactBloc.getImage(ImageSource.camera)
                          },
                      child: Text(
                        StringConstants.CAMERA,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildAvatarImage(BuildContext context) {
    return BlocBuilder(
        bloc: _contactBloc,
        builder: (BuildContext context, ContactState state) {
          return Stack(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: state.selectedContact.avatar != null
                      ? FileImage(File(state.selectedContact.avatar))
                      : null,
                  child: state.selectedContact.avatar == null
                      ? Icon(
                          Icons.account_circle,
                          size: 100,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                      ),
                      onPressed: () => _openImagePicker(context)),
                ),
              )
            ],
          );
        });
  }

  Widget _buildNameField() {
    return TextFormField(
      initialValue: _contactBloc.state.selectedContact.name,
      maxLength: 30,
      decoration: InputDecoration(
          labelText: StringConstants.NAME,
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.text,
      validator: (String value) {
        return value.isEmpty ? StringConstants.PLEASE_ENTER_NAME : null;
      },
      onSaved: (String value) {
        _contactBloc.state.selectedContact.name = value;
      },
    );
  }

  Widget _buildLabel(AppPhone phone) {
    return TextFormField(
      initialValue: phone.label,
      maxLength: 10,
      decoration: InputDecoration(
          labelText: StringConstants.LABEL,
          filled: true,
          fillColor: Colors.white),
      keyboardType: TextInputType.text,
      onSaved: ((String value) {
        phone.label = value;
      }),
      validator: (String value) {
        return value.isEmpty ? StringConstants.PLEASE_ENTER_LABEL : null;
      },
    );
  }

  Widget _buildNumber(AppPhone phone) {
    return TextFormField(
        initialValue: phone.number,
        maxLength: 14,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
            labelText: StringConstants.NUMBER,
            filled: true,
            fillColor: Colors.white),
        onSaved: ((String value) {
          phone.number = value;
        }),
        validator: (String value) {
          return value.isEmpty ? StringConstants.PLEASE_ENTER_NUMBER : null;
        });
  }

  void _addOrUpdateContact(BuildContext context) {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      _contactBloc.insetOrUpdateContactInDb().then((_) {
        Navigator.pop(context);
      });
    }
  }

  Widget _buildPhoneNumber() {
    return Expanded(
      child: BlocBuilder(
        bloc: _contactBloc,
        builder: (BuildContext context, ContactState state) {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: state.selectedContact.phoneList == null
                ? 0
                : state.selectedContact.phoneList.length,
            itemBuilder: (BuildContext context, int index) {
              return Row(
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: _buildLabel(state.selectedContact.phoneList[index]),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    flex: 6,
                    child: _buildNumber(state.selectedContact.phoneList[index]),
                  ),
                  if (index != 0)
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => _contactBloc.removePhoneNumber(index))
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSubmitDeleteButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: RaisedButton(
              onPressed: () => _addOrUpdateContact(context),
              child: Text(StringConstants.SAVE)),
        ),
        Visibility(
          visible: _contactBloc.state.selectedContact != null &&
              _contactBloc.state.selectedContact.id != null,
          child: SizedBox(
            width: 10.0,
          ),
        ),
        Visibility(
          visible: _contactBloc.state.selectedContact != null &&
              _contactBloc.state.selectedContact.id != null,
          child: Expanded(
            child: RaisedButton(
                onPressed: () => _contactBloc
                    .deleteContact()
                    .then((value) => Navigator.pop(context)),
                child: Text(StringConstants.DELETE)),
          ),
        )
      ],
    );
  }

  Widget _buildBodyUi(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        color: Colors.grey.shade100,
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              _buildAvatarImage(context),
              SizedBox(
                height: 10.0,
              ),
              _buildNameField(),
              BlocBuilder(
                bloc: _contactBloc,
                builder: (BuildContext context, ContactState state) {
                  return SwitchListTile(
                    value: state.selectedContact.favorite,
                    onChanged: (bool value) =>
                        _contactBloc.changeFavourite(value),
                    title: Text(StringConstants.FAVOURITE),
                  );
                },
              ),
              BlocBuilder(
                bloc: _contactBloc,
                builder: (BuildContext context, ContactState state) {
                  if (state.selectedContact.phoneList.length < 5)
                    return Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: _contactBloc.addPhoneNumber,
                        child: Text(
                          StringConstants.ADD_NUMBER,
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    );
                  else
                    return Container();
                },
              ),
              _buildPhoneNumber(),
              _buildSubmitDeleteButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _contactBloc = BlocProvider.of<ContactBloc>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(StringConstants.ADD_CONTACT),
      ),
      body: FutureBuilder(
          future: _contactBloc.fetchContactNumbers(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState != ConnectionState.done)
              return Center(
                child: CircularProgressIndicator(),
              );
            else
              return _buildBodyUi(context);
          }),
    );
  }
}
