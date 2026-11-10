class SocialPostModel {
  final String id;
  final String authorName;
  final String authorAvatar;
  final DateTime timestamp;
  final String courseName;
  final int? scoreGross;
  final int? scoreNet;
  final String? diffVsPar;
  final String textContent;
  final int likesCount;
  final bool isLikedByMe;
  final int commentsCount;
  final int? firPct;
  final int? girPct;

  const SocialPostModel({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.timestamp,
    required this.courseName,
    this.scoreGross,
    this.scoreNet,
    this.diffVsPar,
    required this.textContent,
    this.likesCount = 0,
    this.isLikedByMe = false,
    this.commentsCount = 0,
    this.firPct,
    this.girPct,
  });

  SocialPostModel copyWith({
    String? id,
    String? authorName,
    String? authorAvatar,
    DateTime? timestamp,
    String? courseName,
    int? scoreGross,
    int? scoreNet,
    String? diffVsPar,
    String? textContent,
    int? likesCount,
    bool? isLikedByMe,
    int? commentsCount,
    int? firPct,
    int? girPct,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      timestamp: timestamp ?? this.timestamp,
      courseName: courseName ?? this.courseName,
      scoreGross: scoreGross ?? this.scoreGross,
      scoreNet: scoreNet ?? this.scoreNet,
      diffVsPar: diffVsPar ?? this.diffVsPar,
      textContent: textContent ?? this.textContent,
      likesCount: likesCount ?? this.likesCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      commentsCount: commentsCount ?? this.commentsCount,
      firPct: firPct ?? this.firPct,
      girPct: girPct ?? this.girPct,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'timestamp': timestamp.toIso8601String(),
      'courseName': courseName,
      'scoreGross': scoreGross,
      'scoreNet': scoreNet,
      'diffVsPar': diffVsPar,
      'textContent': textContent,
      'likesCount': likesCount,
      'isLikedByMe': isLikedByMe ? 1 : 0,
      'commentsCount': commentsCount,
      'firPct': firPct,
      'girPct': girPct,
    };
  }

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    return SocialPostModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorAvatar:
          json['authorAvatar'] as String? ?? 'assets/images/avatar_safeer.png',
      timestamp: DateTime.parse(json['timestamp'] as String),
      courseName: json['courseName'] as String? ?? 'Championship Course',
      scoreGross: json['scoreGross'] as int?,
      scoreNet: json['scoreNet'] as int?,
      diffVsPar: json['diffVsPar'] as String?,
      textContent: json['textContent'] as String,
      likesCount: json['likesCount'] as int? ?? 0,
      isLikedByMe: (json['isLikedByMe'] == 1 || json['isLikedByMe'] == true),
      commentsCount: json['commentsCount'] as int? ?? 0,
      firPct: json['firPct'] as int?,
      girPct: json['girPct'] as int?,
    );
  }
}

class SocialCommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime timestamp;

  const SocialCommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SocialCommentModel.fromJson(Map<String, dynamic> json) {
    return SocialCommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar:
          json['authorAvatar'] as String? ?? 'assets/images/avatar_player2.png',
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
