/// Teammate Model for tournament registration
class TeammateModel {
  final String id;
  final String name;
  final String? email;
  final String? mobile;
  final String? avatarUrl;
  final String? role;
  final bool isRegistered;

  TeammateModel({
    required this.id,
    required this.name,
    this.email,
    this.mobile,
    this.avatarUrl,
    this.role,
    this.isRegistered = true,
  });

  TeammateModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? avatarUrl,
    bool? isRegistered,
  }) {
    return TeammateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  static List<TeammateModel> getMockTeammates() {
    return [
      TeammateModel(
        id: '1',
        name: 'Marcus Johnson',
        email: 'marcus.j@email.com',
        mobile: '+1 234 567 8901',
        avatarUrl: 'assets/images/avatars/avatar1.png',
      ),
      TeammateModel(
        id: '2',
        name: 'Sarah Chen',
        email: 'sarah.chen@email.com',
        mobile: '+1 234 567 8902',
        avatarUrl: 'assets/images/avatars/avatar2.png',
      ),
      TeammateModel(
        id: '3',
        name: 'Lisa Park',
        email: 'lisa.park@email.com',
        mobile: '+1 234 567 8903',
        avatarUrl: 'assets/images/avatars/avatar3.png',
      ),
      TeammateModel(
        id: '4',
        name: 'James Wilson',
        email: 'james.w@email.com',
        mobile: '+1 234 567 8904',
        avatarUrl: 'assets/images/avatars/avatar4.png',
      ),
      TeammateModel(
        id: '5',
        name: 'Emily Davis',
        email: 'emily.d@email.com',
        mobile: '+1 234 567 8905',
        avatarUrl: 'assets/images/avatars/avatar5.png',
      ),
      TeammateModel(
        id: '6',
        name: 'Michael Brown',
        email: 'michael.b@email.com',
        mobile: '+1 234 567 8906',
        avatarUrl: 'assets/images/avatars/avatar6.png',
      ),
    ];
  }
}
