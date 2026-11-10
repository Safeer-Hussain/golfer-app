class PlayerModel {
  final String id;
  final String name;
  final double handicapIndex;
  final String avatarAsset;
  final String teeBox;
  final int courseHandicap;
  final bool isCurrentDeviceUser;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.handicapIndex,
    required this.avatarAsset,
    required this.teeBox,
    this.courseHandicap = 0,
    this.isCurrentDeviceUser = false,
  });

  PlayerModel copyWith({
    String? id,
    String? name,
    double? handicapIndex,
    String? avatarAsset,
    String? teeBox,
    int? courseHandicap,
    bool? isCurrentDeviceUser,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      handicapIndex: handicapIndex ?? this.handicapIndex,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      teeBox: teeBox ?? this.teeBox,
      courseHandicap: courseHandicap ?? this.courseHandicap,
      isCurrentDeviceUser: isCurrentDeviceUser ?? this.isCurrentDeviceUser,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handicapIndex': handicapIndex,
      'avatarAsset': avatarAsset,
      'teeBox': teeBox,
      'courseHandicap': courseHandicap,
      'isCurrentDeviceUser': isCurrentDeviceUser,
    };
  }

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      handicapIndex: (json['handicapIndex'] as num).toDouble(),
      avatarAsset:
          json['avatarAsset'] as String? ?? 'assets/images/avatar_safeer.png',
      teeBox: json['teeBox'] as String? ?? 'Championship Black',
      courseHandicap: (json['courseHandicap'] as num?)?.toInt() ?? 0,
      isCurrentDeviceUser: json['isCurrentDeviceUser'] as bool? ?? false,
    );
  }
}
