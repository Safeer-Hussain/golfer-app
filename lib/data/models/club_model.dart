class ClubModel {
  final String id;
  final String name;
  final String category;
  final String loft;
  final int carryYards;
  final int totalYards;
  final int recordedShotsCount;
  final String imageAsset;

  const ClubModel({
    required this.id,
    required this.name,
    required this.category,
    required this.loft,
    required this.carryYards,
    required this.totalYards,
    this.recordedShotsCount = 0,
    required this.imageAsset,
  });

  ClubModel copyWith({
    String? id,
    String? name,
    String? category,
    String? loft,
    int? carryYards,
    int? totalYards,
    int? recordedShotsCount,
    String? imageAsset,
  }) {
    return ClubModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      loft: loft ?? this.loft,
      carryYards: carryYards ?? this.carryYards,
      totalYards: totalYards ?? this.totalYards,
      recordedShotsCount: recordedShotsCount ?? this.recordedShotsCount,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'loft': loft,
      'carryYards': carryYards,
      'totalYards': totalYards,
      'recordedShotsCount': recordedShotsCount,
      'imageAsset': imageAsset,
    };
  }

  factory ClubModel.fromJson(Map<String, dynamic> json) {
    return ClubModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      loft: json['loft'] as String,
      carryYards: (json['carryYards'] as num).toInt(),
      totalYards: (json['totalYards'] as num).toInt(),
      recordedShotsCount: (json['recordedShotsCount'] as num?)?.toInt() ?? 0,
      imageAsset: json['imageAsset'] as String? ?? 'assets/images/club_iron.png',
    );
  }

  static List<ClubModel> get default14Clubs => const [
    ClubModel(
      id: 'driver',
      name: 'Driver',
      category: 'Wood',
      loft: '10.5°',
      carryYards: 265,
      totalYards: 285,
      recordedShotsCount: 42,
      imageAsset: 'assets/images/club_driver.png',
    ),
    ClubModel(
      id: '3wood',
      name: '3-Wood',
      category: 'Wood',
      loft: '15.0°',
      carryYards: 235,
      totalYards: 250,
      recordedShotsCount: 28,
      imageAsset: 'assets/images/club_wood.png',
    ),
    ClubModel(
      id: '5wood',
      name: '5-Wood',
      category: 'Wood',
      loft: '18.0°',
      carryYards: 218,
      totalYards: 230,
      recordedShotsCount: 19,
      imageAsset: 'assets/images/club_wood.png',
    ),
    ClubModel(
      id: '4iron',
      name: '4-Iron',
      category: 'Iron',
      loft: '21.0°',
      carryYards: 202,
      totalYards: 212,
      recordedShotsCount: 22,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: '5iron',
      name: '5-Iron',
      category: 'Iron',
      loft: '24.0°',
      carryYards: 190,
      totalYards: 198,
      recordedShotsCount: 31,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: '6iron',
      name: '6-Iron',
      category: 'Iron',
      loft: '27.0°',
      carryYards: 178,
      totalYards: 185,
      recordedShotsCount: 36,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: '7iron',
      name: '7-Iron',
      category: 'Iron',
      loft: '31.0°',
      carryYards: 165,
      totalYards: 172,
      recordedShotsCount: 48,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: '8iron',
      name: '8-Iron',
      category: 'Iron',
      loft: '35.0°',
      carryYards: 152,
      totalYards: 158,
      recordedShotsCount: 45,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: '9iron',
      name: '9-Iron',
      category: 'Iron',
      loft: '40.0°',
      carryYards: 140,
      totalYards: 144,
      recordedShotsCount: 40,
      imageAsset: 'assets/images/club_iron.png',
    ),
    ClubModel(
      id: 'pw',
      name: 'Pitching Wedge',
      category: 'Wedge',
      loft: '45.0°',
      carryYards: 128,
      totalYards: 131,
      recordedShotsCount: 52,
      imageAsset: 'assets/images/club_wedge.png',
    ),
    ClubModel(
      id: 'gw',
      name: 'Gap Wedge',
      category: 'Wedge',
      loft: '50.0°',
      carryYards: 114,
      totalYards: 116,
      recordedShotsCount: 34,
      imageAsset: 'assets/images/club_wedge.png',
    ),
    ClubModel(
      id: 'sw',
      name: 'Sand Wedge',
      category: 'Wedge',
      loft: '54.0°',
      carryYards: 98,
      totalYards: 100,
      recordedShotsCount: 39,
      imageAsset: 'assets/images/club_wedge.png',
    ),
    ClubModel(
      id: 'lw',
      name: 'Lob Wedge',
      category: 'Wedge',
      loft: '58.0°',
      carryYards: 82,
      totalYards: 84,
      recordedShotsCount: 30,
      imageAsset: 'assets/images/club_wedge.png',
    ),
    ClubModel(
      id: 'putter',
      name: 'Putter',
      category: 'Putter',
      loft: '3.0°',
      carryYards: 15,
      totalYards: 35,
      recordedShotsCount: 144,
      imageAsset: 'assets/images/club_putter.png',
    ),
  ];
}
