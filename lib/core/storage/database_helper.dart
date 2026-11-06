import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';
import '../../data/models/club_model.dart';
import '../../data/models/round_scorecard_model.dart';
import '../../data/models/social_post_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE completed_rounds (
        id TEXT PRIMARY KEY,
        course_id TEXT,
        course_name TEXT,
        tee_box TEXT,
        game_format TEXT,
        played_at TEXT,
        player_scores_json TEXT,
        gross_score INTEGER,
        net_score INTEGER,
        is_completed INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE club_bag (
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        loft TEXT,
        carryYards INTEGER,
        totalYards INTEGER,
        recordedShotsCount INTEGER,
        imageAsset TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE social_posts (
        id TEXT PRIMARY KEY,
        authorName TEXT,
        authorAvatar TEXT,
        timestamp TEXT,
        courseName TEXT,
        scoreGross INTEGER,
        scoreNet INTEGER,
        diffVsPar TEXT,
        textContent TEXT,
        likesCount INTEGER,
        isLikedByMe INTEGER,
        commentsCount INTEGER,
        firPct INTEGER,
        girPct INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE social_comments (
        id TEXT PRIMARY KEY,
        postId TEXT,
        authorName TEXT,
        authorAvatar TEXT,
        content TEXT,
        timestamp TEXT
      )
    ''');

    // Seed initial clubs
    final batch = db.batch();
    for (final club in ClubModel.default14Clubs) {
      batch.insert('club_bag', club.toJson());
    }

    // Seed initial clubhouse posts
    final now = DateTime.now();
    final initialPosts = [
      SocialPostModel(
        id: 'post_1',
        authorName: 'Safeer Hussain',
        authorAvatar: 'assets/images/avatar_safeer.png',
        timestamp: now.subtract(const Duration(hours: 3)),
        courseName: 'Lahore Garrison Golf & CC',
        scoreGross: 70,
        scoreNet: 66,
        diffVsPar: '-2',
        textContent: 'Carded 70 (-2) from the Championship Black tees. Driver was dialed in, hitting 11 of 14 fairways. Birdied 7, 11, and 17!',
        likesCount: 18,
        isLikedByMe: true,
        commentsCount: 2,
        firPct: 78,
        girPct: 72,
      ),
      SocialPostModel(
        id: 'post_2',
        authorName: 'M. Khan',
        authorAvatar: 'assets/images/avatar_player2.png',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        courseName: 'Royal Palm Golf & CC',
        scoreGross: 78,
        scoreNet: 70,
        diffVsPar: '+6',
        textContent: 'Great flight with Ali and Zayd. Greens were lightning fast at 11.5 on the stimp. Recovered well on the back nine.',
        likesCount: 11,
        isLikedByMe: false,
        commentsCount: 0,
        firPct: 64,
        girPct: 55,
      ),
      SocialPostModel(
        id: 'post_3',
        authorName: 'Ali Tariq',
        authorAvatar: 'assets/images/avatar_player3.png',
        timestamp: now.subtract(const Duration(days: 2)),
        courseName: 'Emerald Links Golf Resort',
        scoreGross: 84,
        scoreNet: 70,
        diffVsPar: '+13',
        textContent: 'Tough coastal wind at 18 mph today. The AI Caddie suggestion to club up 2 irons on the 16th saved my round.',
        likesCount: 9,
        isLikedByMe: false,
        commentsCount: 0,
        firPct: 50,
        girPct: 44,
      ),
    ];

    for (final post in initialPosts) {
      batch.insert('social_posts', post.toJson());
    }

    // Seed initial comments
    batch.insert('social_comments', {
      'id': 'c_1',
      'postId': 'post_1',
      'authorName': 'Ali Tariq',
      'authorAvatar': 'assets/images/avatar_player3.png',
      'content': 'Outstanding round Safeer. That birdie on 17 was clutch!',
      'timestamp': now.subtract(const Duration(hours: 2)).toIso8601String(),
    });

    batch.insert('social_comments', {
      'id': 'c_2',
      'postId': 'post_1',
      'authorName': 'M. Khan',
      'authorAvatar': 'assets/images/avatar_player2.png',
      'content': 'Great ball striking. See you at the Saturday medal flight.',
      'timestamp': now.subtract(const Duration(hours: 1)).toIso8601String(),
    });

    await batch.commit(noResult: true);
  }

  // Completed Rounds
  Future<int> insertRound(RoundScorecardModel round, {int gross = 0, int net = 0}) async {
    final db = await database;
    return await db.insert(
      'completed_rounds',
      {
        'id': round.id,
        'course_id': round.courseId,
        'course_name': round.courseName,
        'tee_box': round.teeBox,
        'game_format': round.gameFormat,
        'played_at': round.playedAt.toIso8601String(),
        'player_scores_json': jsonEncode(round.toJson()['playerScores']),
        'gross_score': gross,
        'net_score': net,
        'is_completed': 1,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getCompletedRounds() async {
    final db = await database;
    return await db.query('completed_rounds', orderBy: 'played_at DESC');
  }

  // Club Bag
  Future<List<ClubModel>> getClubBag() async {
    final db = await database;
    final maps = await db.query('club_bag');
    if (maps.isEmpty) return ClubModel.default14Clubs;
    return maps.map((m) => ClubModel.fromJson(m)).toList();
  }

  Future<void> updateClub(ClubModel club) async {
    final db = await database;
    await db.update(
      'club_bag',
      {
        'carryYards': club.carryYards,
        'totalYards': club.totalYards,
        'recordedShotsCount': club.recordedShotsCount,
      },
      where: 'id = ?',
      whereArgs: [club.id],
    );
  }

  Future<void> recordClubShot(String clubId, int shotDistance) async {
    final db = await database;
    final results = await db.query('club_bag', where: 'id = ?', whereArgs: [clubId]);
    if (results.isNotEmpty) {
      final current = results.first;
      final currentCarry = current['carryYards'] as int;
      final count = current['recordedShotsCount'] as int;
      final newCount = count + 1;
      final updatedCarry = ((currentCarry * count + shotDistance) / newCount).round();
      final updatedTotal = updatedCarry + ((current['totalYards'] as int) - currentCarry);

      await db.update(
        'club_bag',
        {
          'carryYards': updatedCarry,
          'totalYards': updatedTotal,
          'recordedShotsCount': newCount,
        },
        where: 'id = ?',
        whereArgs: [clubId],
      );
    }
  }

  // Social Posts
  Future<List<SocialPostModel>> getSocialPosts() async {
    final db = await database;
    final maps = await db.query('social_posts', orderBy: 'timestamp DESC');
    return maps.map((m) => SocialPostModel.fromJson(m)).toList();
  }

  Future<int> insertSocialPost(SocialPostModel post) async {
    final db = await database;
    return await db.insert('social_posts', post.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePostLikes(String postId, int likesCount, bool isLiked) async {
    final db = await database;
    await db.update(
      'social_posts',
      {
        'likesCount': likesCount,
        'isLikedByMe': isLiked ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  // Comments
  Future<List<SocialCommentModel>> getCommentsForPost(String postId) async {
    final db = await database;
    final maps = await db.query(
      'social_comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: 'timestamp ASC',
    );
    return maps.map((m) => SocialCommentModel.fromJson(m)).toList();
  }

  Future<int> insertComment(SocialCommentModel comment) async {
    final db = await database;
    final res = await db.insert('social_comments', comment.toJson());
    await db.rawUpdate('''
      UPDATE social_posts 
      SET commentsCount = commentsCount + 1 
      WHERE id = ?
    ''', [comment.postId]);
    return res;
  }
}
