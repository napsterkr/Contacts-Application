import 'package:contactapp/bloc/contact_bloc.dart';
import 'package:contactapp/constants/app_constants.dart';
import 'package:contactapp/pages/add_or_update_contact.dart';
import 'package:contactapp/pages/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State<MyApp> {
  final _contactBloc = ContactBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _contactBloc,
      child: MaterialApp(
        title: StringConstants.APP_NAME,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          RouteConstants.CONTACT_LIST_SCREEN: (BuildContext context) {
            _contactBloc.state.showFav = false;
            return ContactListPage();
          },
        },
        onGenerateRoute: (RouteSettings settings) =>
            _buildGeneratedRoute(settings),
      ),
    );
  }

  ModalRoute _buildGeneratedRoute(RouteSettings settings) {
    final List<String> pathElements =
        settings.name.split(RouteConstants.CONTACT_LIST_SCREEN);
    if (pathElements[0] != '') {
      return null;
    }
    if (pathElements[1] ==
        RouteConstants.ADD_CONTACT_SCREEN
            .replaceAll(RouteConstants.CONTACT_LIST_SCREEN, '')) {
      _contactBloc.initializeSelectedContact(list: []);
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (BuildContext context) => AddOrUpdateContactPage(),
      );
    } else if (pathElements[1] ==
        RouteConstants.UPDATE_CONTACT_SCREEN
            .replaceAll(RouteConstants.CONTACT_LIST_SCREEN, '')) {
      _contactBloc.initializeSelectedContact();
      _contactBloc.state.selectedContact.id = int.parse(pathElements[2]);
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (BuildContext context) => AddOrUpdateContactPage(),
      );
    } else if (pathElements[1] ==
        RouteConstants.FAVOURITE_CONTACT_LIST_SCREEN
            .replaceAll(RouteConstants.CONTACT_LIST_SCREEN, '')) {
      return MaterialPageRoute<bool>(
        settings: settings,
        builder: (BuildContext context) {
          _contactBloc.state.showFav = true;
          return ContactListPage();
        },
      );
    }
    return null;
  }

  @override
  void dispose() {
    _contactBloc.close();
    super.dispose();
  }
}
