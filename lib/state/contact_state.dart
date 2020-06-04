import 'package:contactapp/model/app_contact.dart';

class ContactState {
  final bool showLoader;
  List<AppContact> contactList;
  int contactId;
  bool showFav;
  AppContact selectedContact;

  ContactState(
      {this.showFav = false,
      this.showLoader = false,
      this.contactList,
      this.contactId = -1,
      this.selectedContact});
}
