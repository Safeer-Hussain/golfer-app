import 'package:uuid/uuid.dart';
import '../../core/storage/database_helper.dart';
import '../models/social_post_model.dart';

class ClubhouseRepository {
  final DatabaseHelper _db;
  final Uuid _uuid = const Uuid();

  ClubhouseRepository(this._db);

  Future<List<SocialPostModel>> getPosts() async {
    return await _db.getSocialPosts();
  }

  Future<void> createPost({
    required String authorName,
    required String authorAvatar,
    required String courseName,
    int? scoreGross,
    int? scoreNet,
    String? diffVsPar,
    required String textContent,
    int? firPct,
    int? girPct,
  }) async {
    final post = SocialPostModel(
      id: _uuid.v4(),
      authorName: authorName,
      authorAvatar: authorAvatar,
      timestamp: DateTime.now(),
      courseName: courseName,
      scoreGross: scoreGross,
      scoreNet: scoreNet,
      diffVsPar: diffVsPar,
      textContent: textContent,
      likesCount: 1,
      isLikedByMe: true,
      commentsCount: 0,
      firPct: firPct,
      girPct: girPct,
    );
    await _db.insertSocialPost(post);
  }

  Future<void> togglePostLike(String postId, int currentLikes, bool currentlyLiked) async {
    final newLiked = !currentlyLiked;
    final newCount = newLiked ? currentLikes + 1 : (currentLikes > 0 ? currentLikes - 1 : 0);
    await _db.updatePostLikes(postId, newCount, newLiked);
  }

  Future<List<SocialCommentModel>> getComments(String postId) async {
    return await _db.getCommentsForPost(postId);
  }

  Future<void> addComment({
    required String postId,
    required String authorName,
    required String authorAvatar,
    required String content,
  }) async {
    final comment = SocialCommentModel(
      id: _uuid.v4(),
      postId: postId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      timestamp: DateTime.now(),
    );
    await _db.insertComment(comment);
  }
}
