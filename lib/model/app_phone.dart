class AppPhone {
  int id, contactId;
  String label, number;

  AppPhone({this.contactId, this.label, this.number});

  AppPhone.withId({this.id, this.contactId, this.label, this.number});

  factory AppPhone.fromMap(Map<String, dynamic> map) {
    return AppPhone.withId(
        id: map["id"],
        contactId: map["contactId"],
        label: map["label"],
        number: map["number"]);
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "contactId": contactId,
      "label": label,
      "number": number,
    };
  }
}
