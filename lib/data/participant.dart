class Participant {
  final String firstName;
  final String lastName;
  final String? phone;
  final int? groupId;

  Participant({required this.firstName, required this.lastName, this.phone, this.groupId});

  Participant copyWith({String? firstName, String? lastName, String? phone, int? groupId}) {
    return Participant(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phone: phone ?? this.phone,
        groupId: groupId ?? this.groupId);
  }
}
