class Participant {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final int? groupId;
  final bool isInstructor;

  String get fullName => [firstName, lastName].where((name) => name != null).join(' ');

  Participant({
    required this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.groupId,
    this.isInstructor = false,
  }) : assert(firstName != null || lastName != null, 'Both firstName and lastName cannot be null at the same time.');

  Participant copyWith(
      {String? id, String? firstName, String? lastName, String? phone, int? groupId, bool? isInstructor}) {
    return Participant(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      groupId: groupId ?? this.groupId,
      isInstructor: isInstructor ?? this.isInstructor,
    );
  }

  @override
  String toString() {
    return 'Participant(id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, groupId: $groupId, isInstructor: $isInstructor)';
  }
}
