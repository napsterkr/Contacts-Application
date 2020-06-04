import 'dart:io';

import 'package:contactapp/bloc/contact_bloc.dart';
import 'package:contactapp/constants/app_constants.dart';
import 'package:contactapp/model/app_contact.dart';
import 'package:contactapp/state/contact_state.dart';
import 'package:contactapp/widget/screen_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ContactListPage extends StatelessWidget {
  ContactBloc _contactBloc;

  Widget _buildListView(List<AppContact> contactList) {
    return ListView.builder(
        itemCount: contactList == null ? 0 : contactList.length,
        itemBuilder: (BuildContext context, int index) {
          final contact = contactList[index];
          return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: contact.avatar != null
                    ? FileImage(File(contact.avatar))
                    : null,
                child: contact.avatar == null
                    ? Text(
                        contact.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              title: Text(
                contact.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: contact.favorite ? Icon(Icons.favorite) : null,
              onTap: () => {
                Navigator.pushNamed<bool>(context,
                    RouteConstants.UPDATE_CONTACT_SCREEN + "/${contact.id}")
              },
            ),
          );
        });
  }

  Widget _buildMessage() {
    return BlocBuilder(
        bloc: _contactBloc,
        builder: (BuildContext context, ContactState state) {
          return Visibility(
              visible: !state.showLoader,
              child: ScreenMessage(StringConstants.ADD_CONTACT_ADD_BUTTON));
        });
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: FlatButton(
                child: Text(StringConstants.All_CONTACTS),
                onPressed: () => {
                      if (ModalRoute.of(context).settings.name ==
                          RouteConstants.CONTACT_LIST_SCREEN)
                        {Navigator.pop(context)}
                      else
                        Navigator.pushNamed(
                            context, RouteConstants.CONTACT_LIST_SCREEN),
                    }),
          ),
          Container(
            width: double.infinity,
            child: FlatButton(
                child: Text(StringConstants.ADD_CONTACT),
                onPressed: () => {
                      Navigator.pop(context),
                      Navigator.pushNamed(
                          context, RouteConstants.ADD_CONTACT_SCREEN),
                    }),
          ),
          Container(
            width: double.infinity,
            child: FlatButton(
                child: Text(StringConstants.FAVOURITE_CONTACTS),
                onPressed: () => {
                      if (ModalRoute.of(context).settings.name ==
                          RouteConstants.FAVOURITE_CONTACT_LIST_SCREEN)
                        {Navigator.pop(context)}
                      else
                        Navigator.pushNamed(context,
                            RouteConstants.FAVOURITE_CONTACT_LIST_SCREEN),
                    }),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(_contactBloc.state.showFav
          ? StringConstants.FAVOURITE_CONTACTS
          : StringConstants.CONTACT_LIST),
    );
  }

  Widget _buildFloatingButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          Navigator.pushNamed(context, RouteConstants.ADD_CONTACT_SCREEN)
              .then((value) => null),
      tooltip: StringConstants.ADD_CONTACT,
      child: Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    _contactBloc = BlocProvider.of<ContactBloc>(context);
    _contactBloc.fetchContacts();
    return Scaffold(
      drawer: SafeArea(child: _buildSideDrawer(context)),
      appBar: _buildAppBar(context),
      body: BlocBuilder(
        bloc: _contactBloc,
        builder: (BuildContext context, ContactState state) {
          return Stack(
            children: <Widget>[
              if (state.contactList == null || state.contactList.isEmpty)
                _buildMessage()
              else
                _buildListView(state.contactList),
              Visibility(
                visible: state.showLoader,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingButton(context),
    );
  }
}
