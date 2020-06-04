import 'package:contactapp/constants/app_constants.dart';
import 'package:contactapp/data/app_database.dart';
import 'package:contactapp/model/app_contact.dart';
import 'package:contactapp/model/app_phone.dart';
import 'package:contactapp/state/contact_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ContactBloc extends Bloc<int, ContactState> {
  final _appDatabase = AppDatabase();

  @override
  get initialState => ContactState();

  @override
  Stream<ContactState> mapEventToState(event) async* {
    if (event == AppConstant.showLoader)
      yield ContactState(
          showFav: state.showFav,
          contactList: state.contactList,
          showLoader: true,
          selectedContact: state.selectedContact);
    else if (event == AppConstant.showList)
      yield ContactState(
          showFav: state.showFav,
          contactList: state.contactList,
          showLoader: false,
          selectedContact: state.selectedContact);
    else if (event == AppConstant.modifyContact)
      yield ContactState(
          showFav: state.showFav,
          contactList: state.contactList,
          showLoader: false,
          selectedContact: state.selectedContact);
    else if (event == AppConstant.modifyPhoneNumber)
      yield ContactState(
          showFav: state.showFav,
          contactList: state.contactList,
          showLoader: false,
          selectedContact: state.selectedContact);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
  }

  void addPhoneNumber() {
    if (state.selectedContact.phoneList.length < 5) {
      state.selectedContact.phoneList.add(AppPhone());
      add(AppConstant.modifyPhoneNumber);
    }
  }

  void removePhoneNumber(int index) {
    state.selectedContact.phoneList.removeAt(index);
    add(AppConstant.modifyPhoneNumber);
  }

  void changeFavourite(bool value) {
    state.selectedContact.favorite = value;
    add(AppConstant.modifyContact);
  }

  void initializeSelectedContact({List<AppPhone> list}) {
    state.selectedContact = AppContact(phoneList: list);
  }

  void setSelectedContact(AppContact contact) {
    state.selectedContact = contact;
  }

  Future<void> getImage(ImageSource source) async {
    return await ImagePicker().getImage(source: source).then((value) {
      state.selectedContact.avatar = value.path;
      add(AppConstant.modifyContact);
    });
  }

  //Database Operations

  Future<void> fetchContacts() async {
    add(AppConstant.showLoader);
    var value = await _appDatabase.fetchContacts(state.showFav).then((value) {
      state.contactList = value;
      return value;
    }).catchError(onError);
    add(AppConstant.showList);
    return value;
  }

  Future<int> deleteContact() async {
    add(AppConstant.showLoader);
    var value = await _appDatabase.deleteContact(state.selectedContact.id);
    fetchContacts();
    add(AppConstant.showList);
    return value;
  }

  Future<int> insetOrUpdateContactInDb() async {
    add(AppConstant.showLoader);
    var value = await (state.selectedContact.id == null
            ? _appDatabase.insertContact(state.selectedContact)
            : _appDatabase.updateContact(state.selectedContact))
        .then((value) async {
      fetchContacts();
      return value;
    }).catchError(onError);
    return value;
  }

  Future<void> fetchContactNumbers() async {
    add(AppConstant.showLoader);
    if (state.selectedContact.id != null) {
      await _appDatabase
          .fetchContact(state.selectedContact.id)
          .then((value) => state.selectedContact = value);
    }
    if (state.selectedContact.id != null &&
        (state.selectedContact.phoneList == null ||
            state.selectedContact.phoneList.isEmpty)) {
      var list =
          await _appDatabase.fetchContactNumbers(state.selectedContact.id);
      state.selectedContact.phoneList = list;
    }
    add(AppConstant.modifyContact);
  }
}
