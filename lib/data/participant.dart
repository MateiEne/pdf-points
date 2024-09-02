class Participant {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final int? groupId;

  Participant({this.firstName, this.lastName, this.phone, this.groupId})
      : assert(firstName != null || lastName != null, 'Both firstName and lastName cannot be null at the same time.');

  Participant copyWith({String? firstName, String? lastName, String? phone, int? groupId}) {
    return Participant(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        groupId: groupId ?? this.groupId);
  }
}
