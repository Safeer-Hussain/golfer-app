import 'package:flutter/material.dart';

import '../../data/models/club_model.dart';
import '../../data/models/social_post_model.dart';
import '../../data/repositories/club_bag_repository.dart';
import '../../data/repositories/clubhouse_repository.dart';

class ClubhouseController extends ChangeNotifier {
  final ClubhouseRepository _clubhouseRepository;
  final ClubBagRepository _clubBagRepository;

  List<SocialPostModel> _posts = [];
  List<ClubModel> _clubs = [];
  final Map<String, List<SocialCommentModel>> _commentsCache = {};
  bool _isLoading = false;

  ClubhouseController(this._clubhouseRepository, this._clubBagRepository) {
    loadData();
  }

  List<SocialPostModel> get posts => List.unmodifiable(_posts);
  List<ClubModel> get clubs => List.unmodifiable(_clubs);
  bool get isLoading => _isLoading;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _posts = await _clubhouseRepository.getPosts();
      _clubs = await _clubBagRepository.getClubs();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;

    final post = _posts[idx];
    final isLikedNow = !post.isLikedByMe;
    final newCount = isLikedNow
        ? post.likesCount + 1
        : (post.likesCount > 0 ? post.likesCount - 1 : 0);

    // Instant optimistic update
    _posts[idx] = post.copyWith(isLikedByMe: isLikedNow, likesCount: newCount);
    notifyListeners();

    await _clubhouseRepository.togglePostLike(
      postId,
      post.likesCount,
      post.isLikedByMe,
    );
  }

  Future<void> createMilestonePost({
    required String courseName,
    required String textContent,
    int? scoreGross,
    int? scoreNet,
    String? diffVsPar,
    int? firPct,
    int? girPct,
  }) async {
    await _clubhouseRepository.createPost(
      authorName: 'Safeer Hussain',
      authorAvatar: 'assets/images/avatar_safeer.png',
      courseName: courseName,
      scoreGross: scoreGross,
      scoreNet: scoreNet,
      diffVsPar: diffVsPar,
      textContent: textContent,
      firPct: firPct,
      girPct: girPct,
    );

    _posts = await _clubhouseRepository.getPosts();
    notifyListeners();
  }

  Future<List<SocialCommentModel>> getComments(String postId) async {
    final comments = await _clubhouseRepository.getComments(postId);
    _commentsCache[postId] = comments;
    notifyListeners();
    return comments;
  }

  Future<void> addComment(String postId, String content) async {
    if (content.trim().isEmpty) return;

    await _clubhouseRepository.addComment(
      postId: postId,
      authorName: 'Safeer Hussain',
      authorAvatar: 'assets/images/avatar_safeer.png',
      content: content.trim(),
    );

    // Update post comments count optimistically
    final pIdx = _posts.indexWhere((p) => p.id == postId);
    if (pIdx != -1) {
      _posts[pIdx] = _posts[pIdx].copyWith(
        commentsCount: _posts[pIdx].commentsCount + 1,
      );
    }

    final updated = await _clubhouseRepository.getComments(postId);
    _commentsCache[postId] = updated;
    notifyListeners();
  }

  Future<void> updateClubCalibration(
    ClubModel club,
    int carryYards,
    int totalYards,
  ) async {
    final updated = club.copyWith(
      carryYards: carryYards,
      totalYards: totalYards,
    );
    final idx = _clubs.indexWhere((c) => c.id == club.id);
    if (idx != -1) {
      _clubs[idx] = updated;
      notifyListeners();
    }
    await _clubBagRepository.updateClub(updated);
  }
}
